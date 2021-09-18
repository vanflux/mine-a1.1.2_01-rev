@echo off

echo -=#=- >logs.log
echo Cleanup
call tools\cleanup

echo -=#=- >logs.log
echo Creating temp folder
mkdir temp

echo -=#=- >logs.log
echo Unpacking minecraft.jar
tools\unzip -o bin\minecraft.jar * -d temp\unpacked >>logs.log

echo -=#=- >logs.log
echo Separating resources
mkdir temp\resources
xcopy bin\libs temp\resources\libs\
xcopy bin\natives temp\resources\natives\
move temp\unpacked\armor temp\resources\armor
move temp\unpacked\art temp\resources\art
move temp\unpacked\gui temp\resources\gui
move temp\unpacked\item temp\resources\item
move temp\unpacked\misc temp\resources\misc
move temp\unpacked\mob temp\resources\mob
move temp\unpacked\terrain temp\resources\terrain
move temp\unpacked\title temp\resources\title
move temp\unpacked\*.png temp\resources
move temp\unpacked\*.gif temp\resources

echo -=#=- >logs.log
echo Decompiling
mkdir temp\source
tools\jad -f -dead -ff -safe -stat -v -o -s .java -d temp\source temp\unpacked\*.class 2>>logs.log

echo -=#=- >logs.log
echo Applying file fixes
del temp\unpacked\META-INF\MOJANG_C.DSA 2>NUL:
del temp\unpacked\META-INF\MOJANG_C.SF 2>NUL:
del temp\source\dofix.java 2>NUL:
ren temp\source\do.java dofix.java
del temp\source\iffix.java 2>NUL:
ren temp\source\if.java iffix.java

echo -=#=- >logs.log
echo Applying sourcecode fixes
tools\applydiff -u -i ..\..\patches\minecraft.patch -d temp\source >>logs.log

echo -=#=- >logs.log
echo Decompiling net.minecraft.client.*
echo Applying sourcecode fixes
tools\jad -f -dead -ff -safe -stat -v -o -s .java -d temp\source temp\unpacked\net\minecraft\client\*.class 2>>logs.log

echo -=#=- >logs.log
echo Applying sourcecode fixes
tools\applydiff -u -i ..\..\patches\minecraft.upgrade.patch -d temp\source >>logs.log

echo -=#=- >logs.log
echo Reallocating files
mkdir temp\src
move temp\source temp\src
cd temp\src
rename source java
cd ..\..

echo -=#=- >logs.log
echo Applying patches
call tools\apply_patch_temp patches\0
echo Patches applied, waiting 3 seconds
timeout /t 3

echo -=#=- >logs.log
echo Reallocating source files
mkdir src
mkdir src\main
rd /s /q src\main\java
rd /s /q src\main\resources
move temp\src\java src\main
move temp\resources src\main

echo -=#=- >logs.log
echo Finished!
call tools\cleanup
timeout /t 3
