# Welcome to isantePlus
the github repository for isantePlus contain the openMRS core, all the basic modules for referenceaplication and some other specifics folders for isantePlus.

openMRS-core : is the core for openMRS app

openMRS-module-xxxxxxxxxxxx: is for each module needing

forms : contain the html forms developed for isantePlus

scripts -> isante_to_openmrs : contain the lis of script for migration from isante to openmrs 

scripts-> replication : contain the list of script for replication 

scripts-> update_dictionary : contain the lastest script using to upgrade the ciel dictionairy 


please follow the insctruction below to setup eclipse environement for isantePlus 

1)	The first thing you need to do is go to this link http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
               download and install java jdk1.7
2)	Go to this link http://download.eclipse.org/technology/epp/downloads/release/mars/1/eclipse-jee-mars-1-win32-x86_64.zip ,  Download the zip of eclipse mars version 4.5.1, unzip the folder
3)	Open your github shell, Go to this link https://github.com/openmrs/openmrs-core
4)	In your github shell enter this command: git clone https://github.com/jeandaboul/Isanteplus.git 
5)	Double click on eclipse.exe in your eclipse unzip folder
Go to file->import->Existing maven project->next->browse->go to the path of the github repository on your machine and click on Isanteplus folder-> ok->next


6)	# Steps for Compiling and running the project
a)	For compiling the project-> right click on opemrs ->Run As ->Maven build
b)	In goals enter: "clean install", click run
Here the result:
[INFO] Reactor Summary:
[INFO] 
[INFO] OpenMRS .......................... SUCCESS [  2.567 s]
[INFO] openmrs-tools .................... SUCCESS [  0.003 s]
[INFO] openmrs-test ..................... SUCCESS [  0.001 s]
[INFO] openmrs-api ...................... SUCCESS [  0.022 s]
[INFO] openmrs-web ...................... SUCCESS [  0.002 s]
[INFO] openmrs-webapp ................... SUCCESS [  0.001 s]
[INFO] ------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------
[INFO] Total time: 2.800 s
[INFO] Finished at: 2016-03-21T22:14:40+02:00
[INFO] Final Memory: 7M/18M

c)	For execute the project -> right click on opemrs-webapp->Run As ->Maven build
d)	In goals enter: "jetty:run" and click run
Here the result:
[INFO] Started SelectChannelConnector@0.0.0.0:8080
[INFO] Started Jetty Server
[INFO] Starting scanner at interval of 10 seconds.

e)	Open your web browser and enter localhost:8080/openmrs, follow the steps of openmrs-core installation



Installing module 
For compiling the referenceaplication module, right click on referenceaplication->Run As->Maven build
->in Goals enter "clean install" -> run
After compiling the module, go to your github repository on your machine->open openmrs-module-referenceapplication folder->open omod folder ->open target folder-> copy the .omod file and paste it to the module folder in the path where openmrs is installed
My path is : C:\Users\ITECH\AppData\Roaming\OpenMRS\modules
Repeat these steps for all the modules



