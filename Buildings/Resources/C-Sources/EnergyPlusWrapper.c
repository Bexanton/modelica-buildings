#ifndef _Spawn_declared
#define _Spawn_declared

#include <ModelicaUtilities.h>
#include "EnergyPlusWrapper.h"

/* *********************************************************
   Wrapper functions that connect to the library which
   generates and loads the EnergyPlus fmu.

   Note that ModelicaMessage, ModelicaError,
   ModelicaFormatMessage and ModelicaFormatError are passed
   as function pointers. These functions are provided by,
   and may differ among, the Modelica environments.
   Using function pointers allows the library to load the
   correct version provided by the Modelica simulation
   environment that compiles the Modelica model.
/* ********************************************************* */

/* Custom implementation of ModelicaFormatMessage that prints to stdout
#define my_printf(...) MyModelicaFormatMessage(__VA_ARGS__)
void my_printf(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args);
    va_end(args);
    fflush(stdout);
}
*/

/* Thermal zone */


void* SpawnInputOutputAllocate(
  const char* modelicaNameBuilding,
  const char* modelicaNameThermalZone,
  const char* idfName,
  const char* weaName,
  const char* epName,
  int usePrecompiledFMU,
  const char* fmuName,
  const char* buildingsLibraryRoot,
  const int logLevel,
  const char* jsonName,
  const char* jsonKeysValues,
  char** parOutNames,
  const size_t nParOut,
  char** parOutUnits,
  const size_t nParOutUni,
  char** inpNames,
  const size_t nInp,
  char** inpUnits,
  const size_t nInpUni,
  char** outNames,
  const size_t nOut,
  char** outUnits,
  const size_t nOutUni,
  const int* derivatives_structure,
  size_t k,
  size_t n,
  const double* derivatives_delta,
  const size_t nDer){

    return EnergyPlusExchangeAllocate(
      modelicaNameBuilding,
      modelicaNameThermalZone,
      idfName,
      weaName,
      epName,
      usePrecompiledFMU,
      fmuName,
      buildingsLibraryRoot,
      logLevel,
      jsonName,
      jsonKeysValues,
      (const char**)parOutNames,
      nParOut,
      (const char**)parOutUnits,
      nParOutUni,
      (const char**)inpNames,
      nInp,
      (const char**)inpUnits,
      nInpUni,
      (const char**)outNames,
      nOut,
      (const char**)outUnits,
      nOutUni,
      derivatives_structure,
      k, /* k = 2 in Modelica */
      n,
      derivatives_delta,
      nDer,
      ModelicaMessage,
      ModelicaError,
      ModelicaFormatMessage,
      ModelicaFormatError);
  }

void SpawnInputOutputInstantiate(
    void* object,
    double startTime,
    double *parOut){
      EnergyPlusInputOutputInstantiate(object, startTime, parOut);
}

void SpawnInputOutputExchange(
  void* object,
  int initialCall,
  const double* u,
  double AFlo,
  double* y){

    EnergyPlusInputOutputExchange(
      object,
      initialCall,
      u,
      y);
  }

void SpawnInputOutputFree(void* object){

    EnergyPlusInputOutputFree(object);
}

/* ********************************************************* */
/* Input variables */
void* SpawnInputVariableAllocate(
  const int objectType,
  const char* modelicaNameBuilding,
  const char* modelicaNameInputVariable,
  const char* idfName,
  const char* weaName,
  const char* name,
  const char* componentType,
  const char* controlType,
  const char* unit,
  int usePrecompiledFMU,
  const char* fmuName,
  const char* buildingsLibraryRoot,
  const int logLevel){

    return EnergyPlusInputVariableAllocate(
      objectType,
      modelicaNameBuilding,
      modelicaNameInputVariable,
      idfName,
      weaName,
      name,
      componentType,
      controlType,
      unit,
      usePrecompiledFMU,
      fmuName,
      buildingsLibraryRoot,
      logLevel,
      ModelicaMessage,
      ModelicaError,
      ModelicaFormatMessage,
      ModelicaFormatError);
  }

void SpawnInputVariableInstantiate(void* object, double t0){

    EnergyPlusInputVariableInstantiate(object, t0);
  }

void SpawnInputVariableExchange(
  void* object,
  int initialCall,
  double u,
  double time,
  double* y){

    EnergyPlusInputVariableExchange(object, initialCall, u, time, y);
  }

void SpawnInputVariableFree(void* object){

    EnergyPlusInputVariableFree(object);
  }

/* ********************************************************* */
/* Output variables */
void* SpawnOutputVariableAllocate(
  const char* modelicaNameBuilding,
  const char* modelicaNameOutputVariable,
  const char* idfName,
  const char* weaName,
  const char* variableName,
  const char* componentKey,
  int usePrecompiledFMU,
  const char* fmuName,
  const char* buildingsLibraryRoot,
  const int logLevel,
  int printUnit){

    return EnergyPlusOutputVariableAllocate(
      modelicaNameBuilding,
      modelicaNameOutputVariable,
      idfName,
      weaName,
      variableName,
      componentKey,
      usePrecompiledFMU,
      fmuName,
      buildingsLibraryRoot,
      logLevel,
      printUnit,
      ModelicaMessage,
      ModelicaError,
      ModelicaFormatMessage,
      ModelicaFormatError);
  }

void SpawnOutputVariableInstantiate(void* object, double t0){
    EnergyPlusOutputVariableInstantiate(object, t0);
  }

void SpawnOutputVariableExchange(
  void* object,
  int initialCall,
  double directDependency,
  double time,
  double* y,
  double* tNext){

    EnergyPlusOutputVariableExchange(object, initialCall, directDependency, time, y, tNext);
  }

void SpawnOutputVariableFree(void* object){

    EnergyPlusOutputVariableFree(object);
  }

#endif
