#!/bin/sh

if [[ -z "$GID" ]]; then
	GID="$UID"
fi

# Define functions.
function fixperms {
	chown -R $UID:$GID /data

	# /opt/mautrix-meta is read-only, so disable file logging if it's pointing there.
	if [[ "$(yq e '.logging.writers[1].filename' /data/config.yaml)" == "./logs/mautrix-meta.log" ]]; then
		yq -I4 e -i 'del(.logging.writers[1])' /data/config.yaml
	fi
}

if [[ ! -f /data/config.yaml ]]; then
	/usr/bin/mautrix-meta -c /data/config.yaml -e
	
	# ADD THIS: Set Instagram mode automatically
	yq -I4 e -i '.meta.mode = "instagram"' /data/config.yaml
	
	echo "Generated config file at /data/config.yaml"
	echo "Instagram mode has been set automatically."
	echo "Modify config.yaml to add your homeserver details."
	echo "Start the container again after that to generate the registration file."
	exit
fi

if [[ ! -f /data/registration.yaml ]]; then
	/usr/bin/mautrix-meta -g -c /data/config.yaml -r /data/registration.yaml || exit $?
	echo "Generated registration file."
	echo "Add this to your Synapse appservice configuration."
	echo "See https://docs.mau.fi/bridges/general/registering-appservices.html"
	exit
fi

cd /data
fixperms
exec su-exec $UID:$GID /usr/bin/mautrix-meta
