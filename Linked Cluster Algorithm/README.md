#LINKED CLUSTER ALGORITHM

The linked cluster algorithm is implemented in small sensor networks to form clusters. It performs the selection by means of the unique identifier (ID) of the sensor, defining the neighbor of lower ID as a Cluster Head (CH).
This algorithm was implemented in the nesC programming language.

To test the code on the TOSSIM network simulator, run the following command on the terminal:

    make micaz sim

Then run the python file through this command:

    python test.py

Finally open the log.txt file to check out the application. This can be done in the terminal using:

    cat log.txt

Implemented by: Alexandre Ordakowski, alexandre.ordako@gmail.com
