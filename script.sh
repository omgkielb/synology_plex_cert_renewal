#!/bin/bash

### Inputs ###
# File needs to be added to Plex under Settings -> Network -> Custom certificate location #
# Ensure you also update the Custom certificate domain and Custom server access URLs on the same plage #
plex_cert_path=PATH_TO_PFX_FILE
domain_name=NAME_OF_FILE
# File Path and Name used to generate and place PFX in specific Directory #
# Ensure Plex user has access to system path/file #
p12_file_path="$plex_cert_path/$domain_name.pfx"
# Password needs to be added to Plex under Settings -> Network -> Custom certificate encryption key #
# Update to your own password #
p12cert_password=REPLACE_PASSWORD

### Below values can remain the same ###
# Synology's Default Let's encrypt folder #
letsencrypt_cert_folder=/usr/syno/etc/certificate/system/default
## There will be both RSA/ECC in this folder with DSM 7 ##
# ECC: You want high security with better performance, support modern devices, increased mobile user speed #
# RSA: You must support very old legacy systems, or your NAS has limited support for ECC #
# If unsure of your certs just uncomment the below, enable task to via email to see outputs. #
# ls -al $letsencrypt_cert_folder
cert_prefix="ECC-"

### Used in below scripts ###
current_certificate_date=$(openssl-3 x509 -enddate -noout -in "$letsencrypt_cert_folder/${cert_prefix}cert.pem" | cut -d'=' -f2)

## Check if PFX file exists or if the certificate is past its renewal date ##
if [[ ! -f "$p12_file_path" ]] || ! openssl-3 x509 -checkend 0 -noout -in "$letsencrypt_cert_folder/${cert_prefix}cert.pem"; then
  echo "Generating the p12 certificate file."
  rm -f "$p12_file_path"
  openssl-3 pkcs12 -export -out "$p12_file_path" \
    -in "$letsencrypt_cert_folder/${cert_prefix}cert.pem" \
    -inkey "$letsencrypt_cert_folder/${cert_prefix}privkey.pem" \
    -certfile "$letsencrypt_cert_folder/${cert_prefix}fullchain.pem" \
    -name "$domain_name" \
    -password "pass:$p12cert_password" \
    -certpbe AES-256-CBC -keypbe AES-256-CBC -macalg SHA256
  chmod +r "$p12_file_path"
  chown admin:users "$p12_file_path"
  echo "Plex Certificate will expire on the ${current_certificate_date}."
  echo "Restarting Plex Media Server."
  synopkg restart PlexMediaServer
  echo "Done."
else
  echo "Plex Certificate does not need to be replaced."
  echo "Expiry date is ${current_certificate_date}."
fi
