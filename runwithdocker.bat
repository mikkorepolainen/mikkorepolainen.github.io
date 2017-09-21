@echo off
REM for /f "usebackq tokens=*" %%a in (`pwd`) do docker run --rm -it -v %%a:/usr/src/app -p "4000:4000" starefossen/github-pages
docker run --rm -it -v %cd%:/usr/src/app -p "4000:4000" starefossen/github-pages

