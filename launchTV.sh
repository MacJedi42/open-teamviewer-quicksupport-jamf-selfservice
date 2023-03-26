#!/bin/bash
## Author: Sebastian Whincop
##
## Purpose:
## This script ensures that the TeamViewer Quick Support app is present, up-to-date, and configured with the correct branding and pre-set password.
## If TeamViewer is not installed, it will download and install it. If the installed version is outdated, it will update it.
## The script also checks the OS version and installs a compatible TeamViewer version if necessary.
##
## Please note that the script checks if TeamViewer Host and TeamViewer Desktop are running and stops them to prevent conflicts with Quick Support.

#To ensure that the QuickSupport app is correctly configured with a pre-made password and branding, please specify the config ID to be checked.
configID=

#Set the minimum version of TeamViewer. If the minimum version isn't installed then remove the old version and download a new one.
#Usage: If we want to check that the app is at least 15.37.x then set tvmajorVersion to 15 and tvminorVersion to 37.
tvmajorVersion=15
tvminorVersion=37

#Check for TeamViewer Host. If found, unload the service and close the app.
hostprocess=$(sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewerHost);
if [ -n "$hostprocess" ];
	then
		echo "TeamViewer Host is running. Stopping TeamViewer Host so QuickSupport can open..."
		launchctl unload /Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist   
		launchctl unload /Library/LaunchDaemons/com.teamviewer.Helper.plist
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl unload /Library/LaunchAgents/com.teamviewer.teamviewer.plist
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl unload /Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist
		#launchctl remove /Library/PrivilegedHelperTools/com.teamviewer.Helper
		#rm -rf /Library/PrivilegedHelperTools/com.teamviewer.Helper

		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewerHost | xargs sudo kill -9
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer_Desktop | xargs sudo kill -9
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer_Desktop_Proxy | xargs sudo kill -9
		pgrep TeamViewer_Service | xargs sudo kill -9
#		host="true"
#		echo $host
	else
		echo 'TeamViewer Host not detected, continuing....'
fi

#Check for TeamViewer Desktop. If found, unload the service and close the app.
desktopprocess=$(sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer_Desktop);
if [ -n "$desktopprocess" ];
	then
		echo "TeamViewer Desktop is running. Stopping TeamViewer Desktop so QuickSupport can open..."
		launchctl unload /Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist   
		launchctl unload /Library/LaunchDaemons/com.teamviewer.Helper.plist
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl unload /Library/LaunchAgents/com.teamviewer.teamviewer.plist
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl unload /Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist
#		launchctl remove /Library/PrivilegedHelperTools/com.teamviewer.Helper
#		rm -rf /Library/PrivilegedHelperTools/com.teamviewer.Helper
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer | xargs sudo kill -9
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer_Service | xargs sudo kill -9
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer_Desktop | xargs sudo kill -9
		sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer_Desktop_Proxy | xargs sudo kill -9
		pgrep TeamViewer_Service | xargs sudo kill -9
#		desktop="true"
#		echo $desktop
	else
		echo 'TeamViewer Desktop not detected, continuing....'
fi
#sleep 5
#if [ "$host" = 'true' ]; then
#			launchctl load /Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist   
#			launchctl load /Library/LaunchDaemons/com.teamviewer.Helper.plist 
#			sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl load /Library/LaunchAgents/com.teamviewer.teamviewer.plist
#			sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl load /Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist
#
#			echo 'True is true'
#		else
#			echo ''
#		fi


##Make sure TeamViewer QuickSupport isn't already running. If $process contains a value, use that value to pass to the kill command and end that process.
process=$(sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer);
if [ -n "$process" ];
	then
echo "A TeamViewer QuickSupport instance is already open. Forcing TeamViewerQS to close..."
sudo -u "$(ls -l /dev/console | awk '{print $3}')" pgrep TeamViewer | xargs sudo kill -9
	else
		echo ""
fi
sleep 1

#Get major and minor version of macOS
majorVersion=$(sw_vers -productVersion | awk -F. '{ print $1; }');
minorVersion=$(sw_vers -productVersion | awk -F. '{ print $2; }');

## If macOS majorVersion is at least BigSur(11.x) or minorVersion is at least Mojave (xx.14), ensure teamviewer is up to date, otherwise install TeamViewer v11.
if [[ $majorVersion -ge 11 || $minorVersion -ge 14 ]]; then
	   echo "Checking TeamViewer Version..."
else
   echo "Warning: The script has detected that the macOS on this device is running a version older than Mojave. Due to compatibility issues, the script will attempt to install the old TeamViewerQS application. Note that older TeamViewer endpoints may become unsupported in the future and may not function properly on older macOS versions."
   curl -sL https://download.teamviewer.com/download/version_11x/TeamViewerQS.dmg -o /tmp/DATV.dmg && rm -rf /Applications/TeamViewerQS.app/ 
   wait
   echo "Mounting DATV.dmg"
   hdiutil attach -nobrowse /tmp/DATV.dmg 2>/dev/null
   sleep 1
   rsync -a /Volumes/TeamViewerQS/TeamViewerQS.app /Applications/ && hdiutil unmount '/Volumes/TeamViewerQS' && rm -f /tmp/DATV.dmg 
   sleep 4
   xattr -w com.TeamViewer.ConfigurationId "$configID" /Applications/TeamViewerQS.app
   sudo -u "$(ls -l /dev/console | awk '{print $3}')" open -F -a /Applications/TeamViewerQS.app/
exit 0   

fi

#If the Quicksupport App exists, check the version and upgrade the app before launching if less than version xx.xx. Otherwise download the app and install it before launching.
if [ -d "/Applications/TeamViewerQS.app" ]
	then
		#Check whether our configuration ID is applied to the QuickSupport App
		configcheck=$(xattr -p com.TeamViewer.ConfigurationId /Applications/TeamViewerQS.app);
		if [ "$configcheck" == "$configID" ]; 
			then
				echo "Config-check identified correct configID continuing........" 
			else
				#Set the ID
				echo "Config-check failed, setting configid to "$configID""
				xattr -w com.TeamViewer.ConfigurationId "$configID" /Applications/TeamViewerQS.app
				
		fi
	
		
		#Get the Major version of the installed TeamViewer. If it passes, check the minorVersion passes.
		versioncheck=$(plutil -p /Applications/TeamViewerQS.app/Contents/Info.plist | awk '/CFBundleShortVersionString/ {print substr($3, 2, length($3)-4)}');		
		#reduce to the majorVersion decimal places only.
		versioncheck=$(echo ${versioncheck:0:2})

	if [ "$versioncheck" -ge "$tvmajorVersion" ]; 
	
	then
		#The Major version passed, check the minor version of the installed TeamViewer. If it passes, open the app. Otherwise update the app.
		#Get the full version variable
		versioncheck=$(plutil -p /Applications/TeamViewerQS.app/Contents/Info.plist | awk '/CFBundleShortVersionString/ {print substr($3, 2, length($3)-4)}');
		#reduce to the minorVersion decimal places only.		
		versioncheck=$(echo ${versioncheck:3:5})
		#If versioncheck is greater than or equal to tvminorVersion open TeamViewer Quicksupport, otherwise update.
			if [ "$versioncheck" -ge "$tvminorVersion" ]; 

				then
					#Minor Version is out of date
				#	echo "$versioncheck is greater than or equal to minorversion $tvminorVersion - don't do the update"
					echo "Minimum TeamViewer app version is "$tvmajorVersion"."$tvminorVersion""
					versioncheck=$(plutil -p /Applications/TeamViewerQS.app/Contents/Info.plist | awk '/CFBundleShortVersionString/ {print substr($3, 2, length($3)-4)}');
					echo "Detected TeamViewer app version is $versioncheck"
					echo "TeamViewer is at least version $tvmajorVersion.$tvminorVersion"
					echo "Opening TeamViewer QuickSupport"
					echo ""
					sudo -u "$(ls -l /dev/console | awk '{print $3}')" open -F -a /Applications/TeamViewerQS.app/
				else
				#	echo "$versioncheck is less than minorversion $tvminorVersion - do the update"
					echo "`date`"
					echo "Minimum TeamViewer app version is $tvmajorVersion.$tvminorVersion"
					versioncheck=$(plutil -p /Applications/TeamViewerQS.app/Contents/Info.plist | awk '/CFBundleShortVersionString/ {print substr($3, 2, length($3)-4)}');
					echo "Detected TeamViewer app version is $versioncheck"
					echo "TeamViewer QuickSupport is out of date, upgrading ..."	
					/usr/local/bin/jamf displayMessage -message "TeamViewer QuickSupport must be upgraded before we can continue. This should take less than a minute, then TeamViewer will open."
					rm -rf /Applications/TeamViewerQS.app

					curl -sL https://download.teamviewer.com/download/TeamViewerQS.dmg -o /tmp/DATV.dmg
					wait
					res=$?
					## If exit code is not 0 (0 is successful), warn the user and abort, otherwise proceed to install into /Applications/
						if [[ "$res" != "0" ]]; then
							echo "Failed to download TeamViewer, please check you can connect to the internet."
							/usr/local/bin/jamf displayMessage -message "Failed to download TeamViewer, please check you can connect to the internet."
							exit 1
						else
							echo "Mounting DATV.dmg"
							hdiutil attach -nobrowse /tmp/DATV.dmg 2>/dev/null
							sleep 1
							rsync -a /Volumes/TeamViewerQS/TeamViewerQS.app /Applications/

							sleep 4
							hdiutil unmount '/Volumes/TeamViewerQS'
							rm -f /tmp/DATV.dmg
									echo "`date`"
									echo "Download Complete - Setting configID"
									xattr -w com.TeamViewer.ConfigurationId "$configID" /Applications/TeamViewerQS.app
									echo "Opening TeamVeiwer QuickSupport"
									sudo -u "$(ls -l /dev/console | awk '{print $3}')" open -F -a /Applications/TeamViewerQS.app/		
							exit 0
						fi


			fi
	else
				#Major Version is out of date
				versioncheck=$(plutil -p /Applications/TeamViewerQS.app/Contents/Info.plist | awk '/CFBundleShortVersionString/ {print substr($3, 2, length($3)-4)}');
				echo "Minimum TeamViewer app version is $tvmajorVersion.$tvminorVersion"
				echo "Detected TeamViewer app version is $versioncheck"
				echo "TeamViewer QuickSupport is out of date, upgrading ..."	
				/usr/local/bin/jamf displayMessage -message "TeamViewer QuickSupport must be upgraded before we can continue. This should take less than a minute, then TeamViewer will open."
				rm -rf /Applications/TeamViewerQS.app

				curl -sL https://download.teamviewer.com/download/TeamViewerQS.dmg -o /tmp/DATV.dmg
				wait
				res=$?
				## If exit code is not 0 (0 is successful), warn the user and abort, otherwise proceed to install into /Applications/
					if [[ "$res" != "0" ]]; then
						echo "Failed to download TeamViewer, please check you can connect to the internet."
						/usr/local/bin/jamf displayMessage -message "Failed to download TeamViewer, please check you can connect to the internet."
						exit 1
					else
						echo "Mounting DATV.dmg"
						hdiutil attach -nobrowse /tmp/DATV.dmg 2>/dev/null
						sleep 1
						rsync -a /Volumes/TeamViewerQS/TeamViewerQS.app /Applications/

						sleep 4
						hdiutil unmount '/Volumes/TeamViewerQS'
						rm -f /tmp/DATV.dmg
								echo "`date`"
								echo "Download Complete - Setting configID"
								xattr -w com.TeamViewer.ConfigurationId "$configID" /Applications/TeamViewerQS.app
								echo "Opening TeamVeiwer QuickSupport"
								sudo -u "$(ls -l /dev/console | awk '{print $3}')" open -F -a /Applications/TeamViewerQS.app/		
					fi
exit 0
	fi
			
					

fi


#		if [ "$host" = 'true' ]; then
#			launchctl load /Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist   
#			launchctl load /Library/LaunchDaemons/com.teamviewer.Helper.plist 
#			sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl load /Library/LaunchAgents/com.teamviewer.teamviewer.plist
#			sudo -u "$(ls -l /dev/console | awk '{print $3}')" launchctl load /Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist
# 
#			echo 'True is true'
#		else
#			echo ''
#		fi

		#exit 0
	#else
	if [ ! -d "/Applications/TeamViewerQS.app" ]
	then	
		/usr/local/bin/jamf displayMessage -message "Self Service was unable to locate TeamViewer QuickSupport, so it will now download it. Once the download is complete, Team Viewer will open automatically. This process should take less than one minute."
		echo "`date`"
		echo "I couldn't find TeamViewer QuickSupport, downloading..."
		curl -sL https://download.teamviewer.com/download/TeamViewerQS.dmg -o /tmp/DATV.dmg
		wait

		res=$?
		## If exit code is not 0 (0 is successful), warn the user and abort, otherwise proceed to install into /Applications/
			if [[ "$res" != "0" ]]; then
				echo "Failed to download TeamViewer, please check you can connect to the internet."
				/usr/local/bin/jamf displayMessage -message "Failed to download TeamViewer, please check you can connect to the internet."
				exit 1
			else
				echo "Mounting DATV.dmg"
				hdiutil attach -nobrowse /tmp/DATV.dmg 2>/dev/null
				sleep 1


		rsync -a /Volumes/TeamViewerQS/TeamViewerQS.app /Applications/

		sleep 4
				hdiutil unmount '/Volumes/TeamViewerQS' 
				rm -f /tmp/DATV.dmg
						echo "`date`"
						echo "Download Complete - Setting configID"
						xattr -w com.TeamViewer.ConfigurationId "$configID" /Applications/TeamViewerQS.app
						echo "Opening TeamVeiwer QuickSupport"
						sudo -u "$(ls -l /dev/console | awk '{print $3}')" open -F -a /Applications/TeamViewerQS.app/		

			fi

	fi
exit 0

