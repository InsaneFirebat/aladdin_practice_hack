@echo off

echo Building Aladdin Practice Hack

cd build
echo Building and pre-patching saveless version
cp Aladdin.sfc Aladdin_Practice_1.0.1.sfc && ..\tools\asar\asar.exe --no-title-check --symbols=wla --symbols-path=Aladdin_InfoHUD.sym ..\src\main.asm Aladdin_Practice_1.0.1.sfc && cd ..

cd build
echo Building and pre-patching savestate version
cp Aladdin.sfc Aladdin_Practice_Savestates_1.0.1.sfc && ..\tools\asar\asar.exe --no-title-check -DFEATURE_SAVESTATES=1 ..\src\main.asm Aladdin_Practice_Savestates_1.0.1.sfc && cd ..

PAUSE
