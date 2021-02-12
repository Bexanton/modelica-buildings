/*
 * Modelica external function to communicate with EnergyPlus.
 *
 * Michael Wetter, LBNL                  2/14/2018
 */

#include "InputOutputAllocate.h"
#include "EnergyPlusFMU.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void initializeDerivativeStructure(
  spawnDerivatives** r,
  const int* derivatives_structure,
  const double* derivatives_delta)
  {
    size_t i;

    for(i = 0; i < (*r)->n; i++){
      /* Below, we subtract 1 because Modelica uses 1-based index, but in C, we use
         0-based index.
         derivatives_structure[i][0] is the index for y
         derivatives_structure[i][1] is the index for u

         Also note that Modelica passes a 1-d array, see
         Modelica Language Specification 3.4, p. 168
      */
      (*r)->structure[i][0] = (size_t)(derivatives_structure[2*i]  ) - 1;
      (*r)->structure[i][1] = (size_t)(derivatives_structure[2*i+1]) - 1;
      (*r)->delta[i] = derivatives_delta[i];
      (*r)->vals[i] = 0;
    }
  }

void initializeUnitsModelica(
  spawnReals** ptrReals,
  const char** vals,
  const char* errMsg,
  void (*SpawnFormatError)(const char *string, ...))
  {
    size_t i;
    for(i = 0; i < (*ptrReals)->n; i++){
      mallocString(
        strlen(vals[i])+1,
        errMsg,
        &( (*ptrReals)->unitsModelica[i] ), SpawnFormatError);
      strcpy( (*ptrReals)->unitsModelica[i], vals[i]);
    }
  }

void checkForDoubleExchangeDeclaration(const struct FMUBuilding* fmuBld, const char* jsonKeysValues, char** doubleSpec){
  size_t iZ;
  FMUInOut** ptrInOut = (FMUInOut**)(fmuBld->exchange);
  for(iZ = 0; iZ < fmuBld->nZon; iZ++){
    if (!strcmp(jsonKeysValues, ptrInOut[iZ]->jsonKeysValues)){
      *doubleSpec = ptrInOut[iZ]->modelicaName;
      break;
    }
  }
  return;
}

void setExchangePointerIfAlreadyInstanciated(const char* modelicaName, FMUInOut** ptrFMUInOut){
  size_t iBui;
  size_t iZon;
  FMUBuilding* ptrBui;
  FMUInOut* zon;
  *ptrFMUInOut = NULL;

  for(iBui = 0; iBui < getBuildings_nFMU(); iBui++){
    ptrBui = getBuildingsFMU(iBui);
    for(iZon = 0; iZon < ptrBui->nZon; iZon++){
      zon = (FMUInOut*)(ptrBui->exchange[iZon]);
      if (strcmp(modelicaName, zon->modelicaName) == 0){
        *ptrFMUInOut = zon;
        return;
      }
    }
  }
  return;
}

/* Create the structure and return a pointer to its address. */
void* EnergyPlusExchangeAllocate(
  const char* modelicaNameBuilding,
  const char* modelicaName,
  const char* idfName,
  const char* weaName,
  const char* epName,
  int usePrecompiledFMU,
  const char* fmuName,
  const char* buildingsLibraryRoot,
  const int logLevel,
  const char* jsonName,
  const char* jsonKeysValues,
  const char** parOutNames,
  const size_t nParOut,
  const char** parOutUnits,
  const size_t nParOutUni,
  const char** inpNames,
  const size_t nInp,
  const char** inpUnits,
  const size_t nInpUni,
  const char** outNames,
  const size_t nOut,
  const char** outUnits,
  const size_t nOutUni,
  const int* derivatives_structure,
  const size_t k,
  const size_t n,
  const double* derivatives_delta,
  const size_t nDer,
  void (*SpawnMessage)(const char *string),
  void (*SpawnError)(const char *string),
  void (*SpawnFormatMessage)(const char *string, ...),
  void (*SpawnFormatError)(const char *string, ...)){
  /* Note: The idfName is needed to unpack the fmu so that the valueReference can be obtained */
  size_t i;
  FMUInOut* ptrInOut;
  const size_t nFMU = getBuildings_nFMU();
  /* Name used to check for duplicate zone entries in the same building */
  char* doubleZoneSpec;

  if (logLevel >= MEDIUM){
    SpawnFormatMessage("---- %s: Entered EnergyPlusExchangeAllocate.\n", modelicaName);
    SpawnFormatMessage("---- %s: Buildings library root is at %s\n", modelicaName, buildingsLibraryRoot);
  }

  /* Check arguments */
  if (nParOut != nParOutUni){
    SpawnFormatMessage("---- %s: Require arguments nParOut and nParOutUni to be equal.\n", modelicaName);
  }
  if (nInp != nInpUni){
    SpawnFormatMessage("---- %s: Require arguments nInp and nInpUni to be equal.\n", modelicaName);
  }
  if (nOut != nOutUni){
    SpawnFormatMessage("---- %s: Require arguments nOut and nOutUni to be equal.\n", modelicaName);
  }
  if (k != 2){
    SpawnFormatMessage("---- %s: Require argument k = 2, obtained k = %i.\n", modelicaName, k);
  }
  if (n != nDer){
    SpawnFormatMessage("---- %s: Require arguments n = nDer, obtained n = %i, nDer = %i.\n",
      modelicaName, n, nDer);
  }

  /* Dymola 2019FD01 calls in some cases the allocator twice. In this case, simply return the previously instanciated zone pointer */
  setExchangePointerIfAlreadyInstanciated(modelicaName, &ptrInOut);
  if (ptrInOut != NULL){
    if (logLevel >= MEDIUM)
      SpawnFormatMessage("---- %s: EnergyPlusExchangeAllocate called more than once for this zone.\n", modelicaName);
    /* Return pointer to this zone */
    return (void*) ptrInOut;
  }
  if (logLevel >= MEDIUM)
    SpawnFormatMessage("---- %s: First call for this instance.\n", modelicaName);

  /* ********************************************************************** */
  /* Initialize the zone */

  if (logLevel >= MEDIUM)
    SpawnFormatMessage("---- %s: Initializing memory for zone.\n", modelicaName);

  ptrInOut = (FMUInOut*) malloc(sizeof(FMUInOut));
  if ( ptrInOut == NULL )
    SpawnError("Not enough memory in EnergyPlusExchangeAllocate.c. to allocate zone.");

  /* Some tools such as OpenModelica may optimize the code resulting in initialize()
     not being called. Hence, we set a flag so we can force it to be called in exchange()
     in case it is not called in initialize().
     This behavior was observed when simulating Buildings.ThermalZones.EnergyPlus.BaseClasses.Validation.FMUInOutAdapter
  */
  ptrInOut->isInstantiated = fmi2False;
  ptrInOut->isInitialized = fmi2False;

  ptrInOut->valueReferenceIsSet = fmi2False;

  /* Assign the Modelica instance name */
  mallocString(
    strlen(modelicaName)+1,
    "Not enough memory in EnergyPlusExchangeAllocate.c. to allocate Modelica instance name.",
    &(ptrInOut->modelicaName),
    SpawnFormatError);
  strcpy(ptrInOut->modelicaName, modelicaName);

  /* Assign the json name */
  mallocString(
    strlen(jsonName)+1,
    "Not enough memory in EnergyPlusExchangeAllocate.c. to allocate json name.",
    &(ptrInOut->jsonName),
    SpawnFormatError);
  strcpy(ptrInOut->jsonName, jsonName);

  /* Assign the json keys and values string */
  mallocString(
    strlen(jsonKeysValues)+1,
    "Not enough memory in EnergyPlusExchangeAllocate.c. to allocate the json keys and values string.",
    &(ptrInOut->jsonKeysValues),
    SpawnFormatError);
  strcpy(ptrInOut->jsonKeysValues, jsonKeysValues);

  /* Allocate parameters, inputs and outputs */
  mallocSpawnReals((size_t)nParOut, &(ptrInOut->parameters), SpawnFormatError);
  mallocSpawnReals((size_t)nInp, &(ptrInOut->inputs), SpawnFormatError);
  mallocSpawnReals((size_t)nOut, &(ptrInOut->outputs), SpawnFormatError);

  /* Allocate derivatives */
  mallocSpawnDerivatives((size_t)nDer, &(ptrInOut->derivatives), SpawnFormatError);

  /* Initialize derivative structure */
  initializeDerivativeStructure(&(ptrInOut->derivatives), derivatives_structure, derivatives_delta);

  /* Initialize units */
  initializeUnitsModelica(
    &(ptrInOut->parameters), parOutUnits, "Failed to allocate memory for Modelica units of parameters", SpawnFormatError);
  initializeUnitsModelica(
    &(ptrInOut->inputs), inpUnits, "Failed to allocate memory for Modelica units of inputs", SpawnFormatError);
  initializeUnitsModelica(
    &(ptrInOut->outputs), outUnits, "Failed to allocate memory for Modelica units of outputs", SpawnFormatError);

  if (logLevel >= MEDIUM)
    SpawnFormatMessage("---- %s: Allocated parameters %p\n", modelicaName, ptrInOut->parameters);
  /* Assign structural data */
  buildVariableNames(
    epName,
    parOutNames,
    ptrInOut->parameters->n,
    &(ptrInOut->parOutNames),
    &(ptrInOut->parameters->fmiNames),
    SpawnFormatError);

  buildVariableNames(
    epName,
    inpNames,
    ptrInOut->inputs->n,
    &(ptrInOut->inpNames),
    &(ptrInOut->inputs->fmiNames),
    SpawnFormatError);

  buildVariableNames(
    epName,
    outNames,
    ptrInOut->outputs->n,
    &(ptrInOut->outNames),
    &(ptrInOut->outputs->fmiNames),
    SpawnFormatError);

  /* ********************************************************************** */
  /* Initialize the pointer for the FMU to which this zone belongs */

  /* Check if there is already an FMU for the Building to which this zone belongs to. */
  ptrInOut->bui = NULL;
  for(i = 0; i < nFMU; i++){
    FMUBuilding* fmu = getBuildingsFMU(i);
    if (logLevel >= MEDIUM){
      SpawnFormatMessage("---- %s: Testing FMU %s for %s.\n", modelicaName, fmu->fmuAbsPat, modelicaNameBuilding);
    }

    if (strcmp(modelicaNameBuilding, fmu->modelicaNameBuilding) == 0){
      if (logLevel >= MEDIUM){
        SpawnFormatMessage("---- %s: FMU %s for %s contains this zone.\n",
          modelicaName, fmu->fmuAbsPat, modelicaNameBuilding);
      }
      /* This is the same FMU as before. */
      doubleZoneSpec = NULL;
      checkForDoubleExchangeDeclaration(fmu, jsonKeysValues, &doubleZoneSpec);
      if (doubleZoneSpec != NULL){
        SpawnFormatError(
          "Modelica model specifies zone '%s' twice, once in %s and once in %s, both belonging to building %s. Each zone must only be specified once per building.",
        jsonKeysValues, modelicaName, doubleZoneSpec, fmu->modelicaNameBuilding);
      }

      if (usePrecompiledFMU){
        if (strlen(fmuName) > 0 && strcmp(fmuName, fmu->precompiledFMUAbsPat) != 0){
          SpawnFormatError("Modelica model specifies two different FMU names for the same building, Check parameter fmuName = %s and fmuName = %s.",
            fmuName, fmu->precompiledFMUAbsPat);
        }
      }

      if (logLevel >= MEDIUM){
        SpawnFormatMessage("---- %s: Assigning zone to building with building at %p\n", modelicaName, fmu);
      }
      ptrInOut->bui = fmu;
      AddZoneToBuilding(ptrInOut, logLevel);

      break;
    }
  }
  /* Check if we found an FMU */
  if (ptrInOut->bui == NULL){
    /* Did not find an FMU. */
    i = AllocateBuildingDataStructure(
      modelicaNameBuilding,
      idfName,
      weaName,
      usePrecompiledFMU,
      fmuName,
      buildingsLibraryRoot,
      logLevel,
      SpawnMessage,
      SpawnError,
      SpawnFormatMessage,
      SpawnFormatError);
    ptrInOut->bui = getBuildingsFMU(i);

    AddZoneToBuilding(ptrInOut, logLevel);

    if (logLevel >= MEDIUM){
      for(i = 0; i < getBuildings_nFMU(); i++){
         SpawnFormatMessage("---- %s: Building %s is at address %p\n",
           modelicaName,
           (getBuildingsFMU(i))->modelicaNameBuilding,
           getBuildingsFMU(i));
      }
      SpawnFormatMessage("---- %s: Exchange ptr is at %p\n", modelicaName, ptrInOut);
    }
  }

  if (logLevel >= MEDIUM)
    SpawnFormatMessage("---- %s: Exiting allocation with zone ptr at %p and building ptr at %p\n", modelicaName, ptrInOut, ptrInOut->bui);
  /* Return a pointer to this zone */
  return (void*) ptrInOut;
}

