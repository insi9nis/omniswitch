# Scripts for OmniVista 2500

These are mostly bash scripts tweaked for OV2500 deployment.

If there are variables exposed to the OV2500, it's probably important to provide them.  In the send script wizard, don't click finish early.  The last page, Define User Variables, will list the available variables.

For instance, get_serial_numbers.script saves a CSV of "system name", "model name", "serial number" to a similarly named csv file and then attempts to tftp that file to a single IP, for all switches.  You need to provide that IP for it to work.

If you want all the serial numbers of devices in your environment, run 3cdaemon or the like, let get_serial_numbers.script rip with your IP plugged in, and use gnu utils or powershell to stitch the output together.  cat * or gc * for instance.
