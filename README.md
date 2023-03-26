TeamViewer QuickSupport Manager

This repository contains a script that manages TeamViewer Quick Support on macOS. The script ensures that TeamViewer Quick Support is present, up-to-date, and configured with the correct branding and pre-set password. If TeamViewer is not installed, it will download and install it. If the installed version is outdated, it will update it. The script also checks the OS version and installs a compatible TeamViewer version if necessary.
Features

    Check and close any running instances of TeamViewer Host or Desktop.
    Ensure that the QuickSupport app is correctly configured with a pre-made password and branding.
    Check for the minimum required version of TeamViewer and update if necessary.
    Compatible with macOS Mojave and later versions.

Usage

    Clone the repository or download the script.
    Open the script in a text editor.
    Set the configID variable to the desired configuration ID.
    Set the tvmajorVersion and tvminorVersion variables to the desired minimum version.
    Save the changes and execute the script.
    To get your configuration ID run " xattr -p com.TeamViewer.ConfigurationId /Applications/TeamViewerQS.app " on your QuckSupport App

Author

Sebastian Whincop
License

This project is licensed under the MIT License - see the LICENSE file for details.
