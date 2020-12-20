# 1.0.0-alpha.1 (xxxx-xx-xx)
* The resurrected player classname displayed in the public messages are now translated
* Debug options are now accessible with the options panel
* Add the french translation for the UI
* The selection of the public messages classes and races can now be done using a dropdown menu (instead of having to write the races or classes names by hand
* Settings are now saved in a simplified format, thanks to the AceDB library. The settings from Thaliz < 1.0 are automatically imported so you will not lost your favorites messages ;-)
* Removed the welcome message, as the information can be found in the _About_ tab from the option panel
* Add the contributors names after the author name in the _About_ tab from the option panel
* The source code has been cleanup up

# 0.6.0 (2020-12-02)
* Thaliz now works in 8 languages and has a French translation for the default resurrection messages
* The number of messages is no more limited to 200
* The configuration panel and the CLI has been reworked:
  * The configuration panel is now available in the dedicated _Addons_ tab from the Blizzard _Interface_ menu (or by using the `/thaliz config` command)
  * UI settings are now grouped in different tabs according to their objectives
  * You can now enable the private message (whisp) independently from the public ones (raid/party, say or yell)
  * The `/thaliz` command is now the only one available (`/thalizversion` and others concatenated commands have been removed).
  * The `/thaliz debug` command is now hidden from the UI and the CLI help, as it should be used by advanced users only
* Removed the message displayed in chat when enabling/disabling the resurrection messages feature
* Standardized the wording about the messages send when rezing someone: these are now only called "messages" (not macros or announcements)

# 0.3.0
* Fixed lua bug when not in raid/party
* Fixed nil player names
* Added target name to button (lets see if it works out)
* Bugfix: Blacklisting of players works now.
