cd builds/web
if exist scat_pit.html if exist index.html del index.html
if exist scat_pit.html ren scat_pit.html index.html

butler push . klungore/scat-pit:web

cd ../windows
butler push . klungore/scat-pit:windows