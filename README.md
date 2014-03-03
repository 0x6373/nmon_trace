nmon_trace
==========

Wrapperscript for nmon

Description
-----------

nmon_trace provides a wrapper script for running 'nmon' to collect performance data on a daily basis.
Currently it's running on AIX and writes on trace file per day.
Also, it provides an easy way to export the data to any monitoring/performance-collection system.

Implementation is mainly done with awk.
