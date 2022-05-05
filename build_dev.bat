@echo off

echo Building Aladdin Practice Hack

cd build
echo Building and pre-patching savestate dev build
cp Aladdin.sfc aaaa_AladdinPrac.sfc && ..\tools\asar\asar.exe --no-title-check -DDEV_BUILD=1 --symbols=wla --symbols-path=Aladdin_InfoHUD.sym ..\src\main.asm aaaa_AladdinPrac.sfc && cd ..

PAUSE
