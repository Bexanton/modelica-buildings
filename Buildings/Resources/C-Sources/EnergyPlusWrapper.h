#ifndef EnergyPlusWrapper_h
#define EnergyPlusWrapper_h

#include <ModelicaUtilities.h>

#include <stdint.h>


/* Check for 64 bit */
/* Windows */
#if _WIN32 || _WIN64
#if _WIN64
#define ENVIRONMENT64
#else
#define ENVIRONMENT32
#endif
#endif

/* gcc */
#if __GNUC__
#if __x86_64__ || __ppc64__
#define ENVIRONMENT64
#else
#define ENVIRONMENT32
#endif
#endif

#ifndef ENVIRONMENT64
#error Modelica Spawn coupling is only supported for Linux 64 bit. Your operating system is not 64 bit.
#endif

/* ********************************************************* */
/* Thermal zone */
extern void* EnergyPlusExchangeAllocate(
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
  void (*SpawnFormatError)(const char *string, ...));

extern void EnergyPlusInputOutputInstantiate(void* object, double t0, double *parOut);

extern void EnergyPlusInputOutputExchange(
  void* object,
  int initialCall,
  const double* u,
  double* y);

extern void EnergyPlusInputOutputFree(void* object);

/* ********************************************************* */
/* Input variables */
extern void* EnergyPlusInputVariableAllocate(
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
  const int logLevel,
  void (*SpawnMessage)(const char *string),
  void (*SpawnError)(const char *string),
  void (*SpawnFormatMessage)(const char *string, ...),
  void (*SpawnFormatError)(const char *string, ...));

extern void EnergyPlusInputVariableInstantiate(void* object, double t0);

extern void EnergyPlusInputVariableExchange(
  void* object,
  int initialCall,
  double u,
  double time,
  double* y);

extern void EnergyPlusInputVariableFree(void* object);

/* ********************************************************* */
/* Output variables */
extern void* EnergyPlusOutputVariableAllocate(
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
  int printUnit,
  void (*SpawnMessage)(const char *string),
  void (*SpawnError)(const char *string),
  void (*SpawnFormatMessage)(const char *string, ...),
  void (*SpawnFormatError)(const char *string, ...));

extern void EnergyPlusOutputVariableInstantiate(void* object, double t0);

extern void EnergyPlusOutputVariableExchange(
  void* object,
  int initialCall,
  double directDependency,
  double time,
  double* y,
  double* tNext);

extern void EnergyPlusOutputVariableFree(void* object);

#endif