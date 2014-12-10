#####################################################################
# nmon_trace.awk                                                    #
# Parses the output of an nmon trace and converts for icinga        #
# cs@brnfck.at 2012.08.21                                           #
# @(#)version 1.3  (c) cs@brnfck.at 2013.01.24"                     #
#####################################################################
# ChangeHistory                                                     #
# cs 1.1 - 1.3  Changed ending condition for old topas/nmon         #
# cs 1.0 - 1.1  Added SEA-statistics for VIO-servers                #
# cs 1.0 - 1.1  Added statistics for FC-Adapters                    #
# cs 0.9 - 1.0  Converted for Icinga output                         #
# cs 0.8 - 0.9  Added munin output (test)                           #
# cs 0.7 - 0.8  Added network, paging, io-adapter output            #
# cs     - 0.7  Initial release                                     #
#####################################################################
# ToDo's                                                            #
# *) Add additional disk statistics                                 #
# *) Add SEA statistics for VIO-servers                             #
# *) Add CPU entitlement statistics                                 #
#####################################################################

#####################################################################
# dumpdata()                                                        #
#-------------------------------------------------------------------#
# Outputs collected data for icinga (into files that can be cat'd   #
# by individual checks                                              #
#####################################################################
function dumpdata()
	{
	#####################
	# Dump CPU statistics
	for (i in CPU_ALL_print)
		{
		printf("%s=%s%%;;;; ",i,Values[Fields["CPU_ALL,"i]]) >TMPDIR"/CPU_ALL.values"
		}
	close(TMPDIR"/CPU_ALL.values")

	########################	
	# Dump Memory statistics
	for (i in MEMNEW_print)
		{
		printf("%s=%s%%;;;; ",i,Values[Fields["MEMNEW,"i]]) >TMPDIR"/MEMNEW.values"
		}
	close(TMPDIR"/MEMNEW.values")

	#########################
	# Dump network statistics
	for (Interface in NetInterfaces)
		{
		###############################################################
		# Also deliver totals for all interfaces, but only selected metrics
		for (i in NET_print)
			{
			printf("%s_%s=%sKB;;;; ",Interface,i,Values[Fields["NET,"Interface"_"i]]) >TMPDIR"/NET.values"
			Totals[i]=Totals[i]+Values[Fields["NET,"Interface"_"i]]
			}
		for (i in Totals)
			{
			printf("%s_%s=%sKB;;;; ","Total",i,Totals[i]) >TMPDIR"/NET.values"
			delete Totals[i]
			}
		for (i in NETPACKET_print)
			{
			printf("%s_%s=%s;;;; ",Interface,i,Values[Fields["NETPACKET,"Interface"_"i]]) >TMPDIR"/NETPACKET.values"
			 }
		for (i in NETSIZE_print)
			{
			printf("%s_%s=%s;;;; ",Interface,i,Values[Fields["NETSIZE,"Interface"_"i]]) >TMPDIR"/NETSIZE.values"
			}

		for (i in NETERROR_print)
			{
			printf("%s_%s=%s;;;; ",Interface,i,Values[Fields["NETERROR,"Interface"_"i]]) >TMPDIR"/NETERROR.values"
			Totals[i]=Totals[i]+Values[Fields["NETERROR,"Interface"_"i]]
			}
		for (i in Totals)
			{
			printf("%s_%s=%s;;;; ","Total",i,Totals[i]) >TMPDIR"/NETERROR.values"
			delete Totals[i]
			}
		}
	close(TMPDIR"/NET.values")
	close(TMPDIR"/NETPACKET.values")
	close(TMPDIR"/NETSIZE.values")
	close(TMPDIR"/NETERROR.values")

	#####################
	# Dump SEA statistics
	for (SEA in SEAInterfaces)
		{
		###############################################################
		# Also deliver totals for all interfaces, but only selected metrics
		for (i in SEA_print)
			{
			printf("%s_%s=%sKB;;;; ",SEA,i,Values[Fields["SEA,"SEA"_"i]]) >TMPDIR"/SEA.values"
			Totals[i]=Totals[i]+Values[Fields["SEA,"SEA"_"i]]
			}
		for (i in Totals)
			{
			printf("%s_%s=%sKB;;;; ","Total",i,Totals[i]) >TMPDIR"/SEA.values"
			delete Totals[i]
			}
		for (i in SEAPACKET_print)
			{
			printf("%s_%s=%s;;;; ",SEA,i,Values[Fields["SEAPACKET,"SEA"_"i]]) >TMPDIR"/SEAPACKET.values"
			}
		}
	close(TMPDIR"/SEA.values")
	close(TMPDIR"/SEAPACKET.values")

	########################
	# Dump paging statistics
	for (i in PAGE_print)
		{
		printf("%s=%s;;;; ",i,Values[Fields["PAGE,"i]]) >TMPDIR"/PAGE.values"
		}
	close(TMPDIR"/PAGE.values")

	############################	
	# Dump io-adapter statistics	
	for (IOAdapter in IOAdapters)
		{
		for (i in IOADAPT_print)
			{
			printf("%s_%s=%s;;;; ",IOAdapter,i,Values[Fields["IOADAPT,"IOAdapter"_"i]]) >TMPDIR"/IOADAPT.values"
			}
		}
	close(TMPDIR"/IOADAPT.values")

	############################	
	# Dump disk statistics	
	for (Disk in Disks)
		{
		# KB/s read/write
		printf("%s_read_KB_per_sec=%sKB;;;; ",Disk,Values[ Fields["DISKREAD,"Disk]]) >TMPDIR"/DISK.values"
		printf("%s_write_KB_per_sec=%sKB;;;; ",Disk,Values[ Fields["DISKWRITE,"Disk]]) >TMPDIR"/DISK.values"
		# Disk busy
		printf("%s_busy_pct=%s;;;; ",Disk,Values[ Fields["DISKBUSY,"Disk]]) >TMPDIR"/DISKBUSY.values"
		# Servicetimes
		printf("%s_read_serv_time=%s;;;; ",Disk,Values[ Fields["DISKREADSERV,"Disk]]) >TMPDIR"/DISKSERVTIME.values"
		printf("%s_write_serv_time=%s;;;; ",Disk,Values[ Fields["DISKWRITESERV,"Disk]]) >TMPDIR"/DISKSERVTIME.values"
		# Sum up totals
		Totals["Total_read_KB_per_sec"]=Totals["Total_read_KB_per_sec"]+Values[ Fields["DISKREAD,"Disk]]
		Totals["Total_write_KB_per_sec"]=Totals["Total_write_KB_per_sec"]+Values[ Fields["DISKWRITE,"Disk]]
		}
	printf("Total_read_KB_per_sec=%sKB;;;; ",Totals["Total_read_KB_per_sec"]) >TMPDIR"/DISK.values"
	printf("Total_write_KB_per_sec=%sKB;;;; ",Totals["Total_write_KB_per_sec"]) >TMPDIR"/DISK.values"
	close(TMPDIR"/DISK.values")
	close(TMPDIR"/DISKBUSY.values")
	close(TMPDIR"/DISKSERVTIME.values")

	############################	
	# Dump fc statistics	
	for (FCAdapter in FCAdapters)
		{
		# KB/s read/write
		printf("%s_read_KB_per_sec=%sKB;;;; ",FCAdapter,Values[ Fields["FCREAD,"FCAdapter]]) >TMPDIR"/FCADAPTER.values"
		printf("%s_write_KB_per_sec=%sKB;;;; ",FCAdapter,Values[ Fields["FCWRITE,"FCAdapter]]) >TMPDIR"/FCADAPTER.values"
		}
	close(TMPDIR"/FCADAPTER.values")

	#########################################
	# Move files into place for munin plugins
	system("mv "TMPDIR"/* "FINALDIR" >/dev/null 2>&1")
	}

#####################################################################
# BEGIN block                                                       #
#-------------------------------------------------------------------#
# Defines which metrics should be printed, this is done by using    #
# associative arrays (for simple loops through metrics)             #
#####################################################################
BEGIN \
	{ 
	#######################################################################
	# Do not dump data on first timestamp (timestamps come before the data)
	havedata=0 
	
	#########################################
	# Define which fields to dump for CPU_ALL
	CPU_ALL_print["UserPCT"]=1
	CPU_ALL_print["SysPCT"]=1
	CPU_ALL_print["WaitPCT"]=1
	CPU_ALL_print["IdlePCT"]=1
	##CPU_ALL_print["PhysicalCPUs"]=1

	########################################
	# Define which fields to dump for MEMNEW
	MEMNEW_print["SystemPCT"]=1
	MEMNEW_print["UserPCT"]=1
	MEMNEW_print["FScachePCT"]=1
	MEMNEW_print["PinnedPCT"]=1

	#####################################
	# Define which fields to dump for NET
	NET_print["read_KB_per_sec"]=1
	NET_print["write_KB_per_sec"]=1

	###########################################
	# Define which fields to dump for NETPACKET
	NETPACKET_print["reads_per_sec"]=1
	NETPACKET_print["writes_per_sec"]=1

	#########################################
	# Define which fields to dump for NETSIZE
	NETSIZE_print["readsize"]=1
	NETSIZE_print["writesize"]=1

	##########################################
	# Define which fields to dump for NETERROR
	NETERROR_print["ierrs"]=1
	NETERROR_print["oerrs"]=1
	NETERROR_print["collisions"]=1

	######################################
	# Define which fields to dump for PAGE
	PAGE_print["faults"]=1
	PAGE_print["pgin"]=1
	PAGE_print["pgout"]=1
	PAGE_print["pgsin"]=1
	PAGE_print["pgsout"]=1
	PAGE_print["reclaims"]=1
	PAGE_print["scans"]=1
	PAGE_print["cycles"]=1

	#########################################
	# Define which fields to dump for IOADAPT
	IOADAPT_print["read_KB_per_sec"]=1
	IOADAPT_print["write_KB_per_sec"]=1
	IOADAPT_print["xfer_tps"]=1

	#####################################
	# Define which fields to dump for SEA
	SEA_print["read_KB_per_sec"]=1
	SEA_print["write_KB_per_sec"]=1

	###########################################
	# Define which fields to dump for SEAPACKET
	SEAPACKET_print["reads_per_sec"]=1
	SEAPACKET_print["writes_per_sec"]=1
	}

#####################################################################
# Data collection block                                             #
#-------------------------------------------------------------------#
# Here all wanted metrics are defined, descriptions are being parsed#
# and data is being collected into arrays.                          #
#####################################################################
$1~/^(CPU_ALL|MEMNEW|NET|NETPACKET|NETSIZE|NETERROR|PAGE|IOADAPT|DISKBUSY|DISKREAD|DISKWRITE|DISKREADSERV|DISKWRITESERV|DISKWAIT|FCREAD|FCWRITE|SEA|SEAPACKET)$/ \
	{ 
	Type=$1
	if ($2 !~ /^T0/)
		{
		#######################################
		# We have found descriptions, save them
		Descriptions[Type]=$2
		# Delete all old fields in the arrays
		for (i in Fields)
			{ if (i~/^$1,/) { delete Fields[i] } }
		for (i in Values)
			{ if (i~/^$1,/) { delete Values[i] } }

		#################################################################
		# Parse available network interfaces for per interface statistics
		if ($1~/^NET$/)
			{ 
			for (i in NetInterfaces)
				{ delete NetInterfaces[i] }
			for (i=3;i<=NF;i++)
				{
				split($i,Metric,"-")
				NetInterfaces[Metric[1]]=Metric[1]
				}
			}

		#############################################
		# Parse available SEAs for per SEA statistics
		if ($1~/^SEA$/)
			{ 
			for (i in SEAInterfaces)
				{ delete SEAInterfaces[i] }
			for (i=3;i<=NF;i++)
				{
				split($i,Metric,"-")
				SEAInterfaces[Metric[1]]=Metric[1]
				}
			}

		########################################################
		# Parse available io-adapters for per adapter statistics
		if ($1~/^IOADAPT$/)
			{ 
			for (i in IOAdapters)
				{ delete IOAdapters[i] }
			for (i=3;i<=NF;i++)
				{
				split($i,Metric,"_")
				IOAdapters[Metric[1]]=Metric[1]
				}
			}

		###############################################
		# Parse available disks for per disk statistics
		if ($1~/^DISKREAD$/)
			{
			for (i in Disks)
				{ delete Disks[i] }
			for (i=3;i<=NF;i++)
				{
				Disks[$i]=$i
				}
			}

		###############################################
		# Parse available disks for per fc statistics
		if ($1~/^FCREAD$/)
			{
			for (i in FCAdapters)
				{ delete FCAdapters[i] }
			for (i=3;i<=NF;i++)
				{
				FCAdapters[$i]=$i
				}
			}

		###########################################
		# Save the new fields (+ modify fieldnames)
		for (i=3;i<=NF;i++)
			{
			# Prepare Fieldname for munin (remove obscure characters, ...)
			Fieldname=$i
			gsub(/[ \t]+$/,"",Fieldname)
			sub(/%/,"PCT",Fieldname)
			sub(/\/s/,"_per_sec",Fieldname)
			gsub(/-/,"_",Fieldname)
			##printf("Found Field %s with index %d\n",Fieldname,i)
			Fields[Type","Fieldname]=Type","i
			}
		}
	else
		{
		##################################
		# We have found a new data entries
		havedata=1
#		printf("Found data for %s: %s\n",Type,$0)
		# Get timestamp information
		Timestamp[Type]=TIMESTAMP[$2]
		# Save data
		for (i=3;i<=NF;i++)
			{
			Values[Type","i]=$i
			}
		}
	} 

#####################################################################
# ZZZZ block                                                        #
#-------------------------------------------------------------------#
# Here we get a new timestamp, save everything and check if we have #
# data which needs to be outputed.                                  #
#####################################################################
$1=="ZZZZ" \
	{
	####################################
	# We have found a timestamp, save it
	TIMESTAMP[$2]=$3","$4

	###################################
	# Dump data if we already have some
	if (havedata==1)
		{
		dumpdata()
		}
	}

#####################################################################
# ending block                                                      #
#-------------------------------------------------------------------#
# This catches the end of an nmon trace, dump the last data and     #
# kill the process (tail) which feeds the pipe to cleanup.          #
#####################################################################
$0~/^BBBP,[^,]*,ending / \
	{
	##############################
	# Dump the last data collected
	dumpdata()
	printf("\n")

	#########################
	# Cleanup (kill tail etc)
	printf("Found end of nmon-file\n")
	printf("Killing tail -f... ")
	system("kill -9 "TAIL_PID)
	exit 0
	}
