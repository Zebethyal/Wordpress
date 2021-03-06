#!/bin/bash

# just in case there's something in /var/www/html that we don't
# want to delete, like an accidental NFS share
mv /var/www/html /var/www/html.bak

if [[ -n $POLYSCRIPT_MODE && $POLYSCRIPT_MODE != 'off' ]]; then

	echo "===================== POLYSCRIPTING ENABLED =========================="
	if [ -d /wordpress ]; then
	    echo "Copying /wordpress to /var/www/html to be polyscripted in place..."
	    echo "This will prevent changes from being saved back to /wordpress, but will protect"
	    echo "against code injection attacks..."
            cp -Rp /wordpress /var/www/html
	fi

	echo "Starting polyscripted WordPress"
	cd $POLYSCRIPT_PATH
	sed -i "/#mod_allow/a \define( 'DISALLOW_FILE_MODS', true );" /var/www/html/shared/wp-config.php
    	./build-scrambled.sh
	if [ -f scrambled.json ] && s_php tok-php-transformer.php -p /var/www/html --replace; then
		echo "Polyscripting enabled."
		echo "done"
	else
		echo "Polyscripting failed."
		cp /usr/local/bin/s_php /usr/local/bin/php
		exit 1
	fi
	if [ -d /uploads ]; then
		ln -s /uploads /var/www/html/shared/wp-content/uploads
	else
		rm  -rf /var/www/html/shared/wp-content/uploads
		ln -s /wordpress/shared/wp-content/uploads /var/www/html/shared/wp-content/uploads
	fi
else
    echo "Polyscripted mode is off. To enable it, set the environment variable: POLYSCRIPT_MODE=polyscripted"

    # Symlink the mount so it's editable
    ln -s /wordpress /var/www/html
fi
