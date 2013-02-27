#!/bin/ash
# Author: william2003[at]gmail[dot]com
# Date: 07/05/2008
# Admin tool to help manage VMs in bulk


##### DO NOT MODIFY PAST THIS LINE ####

REMOTE_MODE=0
#-=-DEFAULT_START-=-#
DEVEL_MODE=

debug () {
	if [ -n "$DEVEL_MODE" ]; then echo [debug] "$@";fi
}

printHeader () {
        echo "###############################################################################"
        echo "#"
        echo "# UCSB ResNet Virtual Machine Managment Tool for VMware ESX 3.x and ESXi"
        echo "# Author: william2003[at]gmail[dot]com"
	echo -e "#\t  duonglt[at]engr[dot]ucsb[dot]edu"
	echo "# Created: 07/05/2008"
        echo "#"
        echo "###############################################################################"
        echo
}

printUsage () {
	SCRIPT_PATH="$( basename $0 )"
        echo "Usage:"
	echo -e "\tLocal execution-\n\t    ${SCRIPT_PATH} [operation] [vm_input_file] <optional_arguments>"
	echo -e "\tRemote execution-\n\t    ${SCRIPT_PATH} remote [ESX_ESXI_IP_ADDRESS] [operation] [vm_input_file] <optional_arguments>"
        echo -e "\n   Operations:"
        echo -e "\tstart [vm_input_file]"
	echo -e "\t   -- Start all VMs in the input file"
	echo -e "\tstop [vm_input_file]"
        echo -e "\t   -- Stop all VMs in the input file"
	echo -e "\tsuspend [vm_input_file]"
        echo -e "\t   -- Suspend all VMs in the input file"
        echo -e "\tresume [vm_input_file]"
        echo -e "\t   -- Resume all suspended VMs in the input file"
	echo -e "\treset [vm_input_file]"
        echo -e "\t   -- Hard reset all VMs in the input file"
        echo -e "\tshutdown [vm_input_file]"
	echo -e "\t   -- Shutdown all VMs in the input file (VMware Tools required)"	
	echo -e "\treboot [vm_input_file]"
	echo -e "\t   -- Reboot all VMs in the input file (VMware Tools required)"
	echo -e "\tsnap [vm_input_file]"
        echo -e "\t   -- Create administrative pristine snapshot of all VMs in the input file"
	echo -e "\trevert [vm_input_file]"
	echo -e "\t   -- Revert all VMs in the input file back to pristine state"
	echo -e "\tpurge [vm_input_file]"
	echo -e "\t   -- Removes from local inventory and purges all VMs in the input file"
	echo -e "\tmac [vm_input_file] [generic|nixdhcp] [NETWORK (172.30.0)] [HOST_COUNT_START (200)] <NIC_#> default=0"
	echo -e "\t   -- Extracts MAC addresses and generates either a generic file or one compatible with *nix dhcpd"
	echo -e "\t       ( e.g. ${SCRIPT_PATH} mac [vm_input_file] generic )"
	echo -e "\t       ( e.g. ${SCRIPT_PATH} mac [vm_input_file] nixdhcp 172.30.0 200 )"
	echo -e "\tvnic [vm_input_file] <NIC_#> default=0"
	echo -e "\t   -- Change vNic portgroup for all VMs in the input file" 
	echo -e "\t       ( e.g. ${SCRIPT_PATH} vnic [vm_input_file] 3 )"
        echo
        exit
}
#-=-DEFAULT_END-=-#

#-=-VALIDATE_IP_FUNC_START-=-#
# http://www.unix.com/shell-programming-scripting/36144-ip-address-validation-function.html
validate_ip () {
	ERROR=0
    	oldIFS=$IFS
    	IFS=.
    	set -f
    	set -- $1
    	if [ $# -eq 4 ]
    	then
      		for seg
      		do
        		case $seg in
            			""|*[!0-9]*) ERROR=1;break ;; ## Segment empty or non-numeric char
            			*) [ $seg -gt 255 ] && ERROR=2 ;;
        		esac
      		done
    	else
      		ERROR=3 ## Not 4 segments
    	fi
    	IFS=$oldIFS
    	set +f
    	return $ERROR
}
#-=-VALIDATE_IP_FUNC_END-=-#

#-=-STARTTIMER_FUNC_START-=-#
startTimer () {
        START_TIME=`date`
        S_TIME=`date +%s`
}
#-=-STARTTIMER_FUNC_END=-=#

#-=-ENDTIMER_FUNC_START-=-#
endTimer () {
        END_TIME=`date`
        E_TIME=`date +%s`
        echo "Start time: ${START_TIME}"
        echo "End   time: ${END_TIME}"
        DURATION=`echo $((E_TIME - S_TIME))`

        #calculate overall completion time
        if [ ${DURATION} -le 60 ]; then
                echo "Duration  : ${DURATION} Seconds"
        else
                echo "Duration  : `awk 'BEGIN{ printf "%.2f\n", '${DURATION}'/60}'` Minutes"
        fi
}
#-=-ENDTIMER_FUNC_END-=-#

#-=-CHECKHOSTTYPE_FUNC_START-=-#
checkHostType () {
	ESX_VER=$(vmware -v | awk '{print $4}')
        if [ -f /bin/vim-cmd ]; then
                VMWARE_CMD=/bin/vim-cmd
        elif [ -f /usr/bin/vmware-vim-cmd ]; then
                VMWARE_CMD=/usr/bin/vmware-vim-cmd
	elif [[ "${ESX_VER}" == "3.0.3" ]] || [[ "${ESX_VER}" == "3.0.2" ]] || [[ "${ESX_VER}" == "3.0.1" ]] || [[ "${ESX_VER}" == "3.0.0" ]]; then
		VMWARE_CMD=/usr/bin/vimsh
		LEGACY_HOST=1
        else
                echo "ERROR: Host type is not ESX 3.x+ or ESXi"
                exit 1
        fi
	ADMIN_RUN=/tmp/admin_run.$$
	mkdir -p "${ADMIN_RUN}"
	if [ "${DEVEL_MODE}" -eq 1 ]; then
		echo "Temp files will be stored in: ${ADMIN_RUN}"
	fi
}
#-=-CHECKHOSTTYPE_FUNC_END-=-#

#-=-DUMPVMS_FUNC_START-=-#
dumpVMs () {
	checkHostType

	ALL_VM_LIST=${ADMIN_RUN}/getallvms_list.$$
	echo "Validating Virtual Machine list against VMs on ESX Server: `hostname`"
	if [ ! "${LEGACY_HOST}" == "1" ]; then
		${VMWARE_CMD} vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | awk -F'   ' '{print "\""$1"\";\""$2"\";\""$3"\""}' |  sed 's/\] /\]\";\"/g' | sed '1,1d' > "${ALL_VM_LIST}" 2>&1
	else
		${VMWARE_CMD} -n -e "vmsvc/getallvms" > "${ALL_VM_LIST}" 2>&1	
	fi
}
#-=-DUMPVMS_FUNC_END-=-#

#-=-VALIDATOR_FUNC_START-=-#
validator () {
	EXP_NUM_OF_ARGS=$1
	NUM_OF_ARGS=$2
	INPUT_FILE=$3

	if [ ! ${NUM_OF_ARGS} -ge ${EXP_NUM_OF_ARGS} ]; then
		echo -e "ERROR: this operation requires at least ${EXP_NUM_OF_ARGS} arguments, please try again\n"
		exit 1
	fi

        if [ ! -f "${INPUT_FILE}" ]; then
	        echo -e "Error: ${INPUT_FILE} is not a valid VM input file!\n"
   		exit 1
        fi

        #dump all virtual machines and sanitize the input and provide back a list of valid virtual machines
        dumpVMs

        CLEANSED_VM_LIST=${ADMIN_RUN}/vm_input_list.$$
        debug "CLEANSED_VM_LIST is ${CLEANSED_VM_LIST}"
        touch "${CLEANSED_VM_LIST}"

        VM_COUNT=0

#        IFS=$'\n'
        for VM_NAME in `cat "${INPUT_FILE}" | sed '/^$/d' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//' | awk '{print $1}'`;
        do
        debug "VM_NAME is: $VM_NAME"
        debug "ALL_VM_LIST is: $ALL_VM_LIST"
		if [ ! "${LEGACY_HOST}" == "1" ]; then
			line=`grep "${VM_NAME}" "${ALL_VM_LIST}"`
			debug "line is: $line"
        		VM_ID=`echo $line | awk -F ";" '{print $1}' | sed 's/"//g'`
		else
			case "${ESX_VER}" in 
				"3.0.0")
					VM_ID=`grep -E "/${VM_NAME}/${VM_NAME}.vmx" -B2 "${ALL_VM_LIST}" | grep "VmId" | awk '{print $3}'`;;
				"3.0.1"|"3.0.2"|"3.0.3")
					VM_ID=`grep -E "${VM_NAME}/${VM_NAME}.vmx" -B2 "${ALL_VM_LIST}" | grep "VmId" | awk '{print $3}'`;;
			esac
		fi
				debug "VM_ID is: $VM_ID"
                if [ -z ${VM_ID} ]; then
                	echo "Unable to locate $VM_NAME" > /dev/null 2>&1
                else
                	echo "\"${VM_ID}\";\"${VM_NAME}\"" >> "${CLEANSED_VM_LIST}"
                        VM_COUNT=$(( ${VM_COUNT} + 1 ))
                fi
        done
#        unset IFS

	#check to make sure we don't have a blank file
	if [ ! -s ${CLEANSED_VM_LIST} ]; then
		echo -e "\nUnable to locate the Virtual Machines specified in the file \"${INPUT_FILE}\", please ensure spelling of the VMs are correct, they're case sensitive!"
		rm -rf ${ADMIN_RUN}
		exit		
	fi
}
#-=-VALIDATOR_FUNC_END-=-#

#-=-SSHRRRSVMS_FUNC_START-=-#
startshutdownhaltrebootresetresumesuspendVMs () {
	CHOICE=$1

	case ${CHOICE} in 
	1)
		QUEST="Power on"
		MSG="Powering on"
		WARN_MSG="powered on"
		if [ ! "${LEGACY_HOST}" == "1" ]; then
			CMD="on"
		else
			CMD="poweron"
		fi
		CHECK_STATE="Powered off"
		;;
	2)
		QUEST="Power off"
		MSG="Powering off"
		WARN_MSG="powered off"
		CMD="shutdown"
		CHECK_STATE="Powered on"
		;;
	3)
		QUEST="Hard power off"
		MSG="Hard power off"
		WARN_MSG="hard power off"
		if [ ! "${LEGACY_HOST}" == "1" ]; then
			CMD="off"
		else
			CMD="poweroff"
		fi
		CHECK_STATE="Powered on"
		;;
	4)
		QUEST="Reboot"
		MSG="Rebooting"
		WARN_MSG="rebooted"
		CMD="reboot"
		CHECK_STATE="Powered on"
		;;
	5)
		QUEST="Restart"
		MSG="Restart"
		WARN_MSG="restarted"
		CMD="reset"
		CHCK_STATE="Powered on"
		;;
	6)	
		QUEST="Resume"
		MSG="Resume"
		WARN_MSG="resumed"
		if [ ! "${LEGACY_HOST}" == "1" ]; then
                        CMD="on"
                else
                        CMD="poweron"
                fi

		CHECK_STATE="Suspended"
		;;
	7)
		QUEST="Suspending"
		MSG="Suspend"
		WARN_MSG="suspended"
		CMD="suspend"
		CHCK_STATE="Powered on"
		;;
	esac

	echo

	if [ "${REMOTE_MODE}" -eq 0 ]; then	
		cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}'

		echo -e "\n${QUEST} the following ${VM_COUNT} Virtual Machine(s) y/n?"
        	read userConfirm
        	case $userConfirm in
                	yes|YES|y|Y)
                        	echo "${MSG} has been confirmed for the following ${VM_COUNT} Virtual machine(s)"
                	        echo;;
                	no|NO|n|N)
                        	echo "${MSG} has been cancelled, script exiting"
				rm -rf "${ADMIN_RUN}"
                        	exit;;
				*) 
				echo "Invalid input, please try again"
				rm -rf "${ADMIN_RUN}"
				exit;;
        	esac
	fi
	startTimer
	#IFS=$'\n'
        for VM_NAME in `cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}' | sed 's/"//g'`;
        do
		VM_ID=`grep -E "\"${VM_NAME}\"" "${CLEANSED_VM_LIST}" | awk -F ";" '{print $1}' | sed 's/"//g'`
		if [ ! "${LEGACY_HOST}" == "1" ]; then
			if ${VMWARE_CMD} vmsvc/power.getstate "${VM_ID}" | grep -E "${CHECK_STATE}" > /dev/null 2>&1; then
				if ! ${VMWARE_CMD} vmsvc/power.${CMD} "${VM_ID}" > /dev/null 2>&1; then
					echo "ERROR: ${MSG} \"${VM_NAME}\" failed!"
				else
					echo "${MSG} : \"$VM_NAME\""
					sleep 2
				fi
			else
				echo "WARNING: ${VM_NAME} can not be ${WARN_MSG}" 
			fi
		else
			if ${VMWARE_CMD} -n -e "vmsvc/powerstate ${VM_ID}" | tail -1 | grep -E "${CHECK_STATE}" > /dev/null 2>&1; then
				if ! ${VMWARE_CMD} -n -e "vmsvc/${CMD} ${VM_ID}" > /dev/null 2>&1; then
				       echo "ERROR: ${MSG} \"${VM_NAME}\" failed!"
                                else
                                        echo "${MSG} : \"$VM_NAME\""
                                        sleep 2
                                fi
			else
                                echo "WARNING: ${VM_NAME} can not be ${WARN_MSG}"
                        fi
		fi
        done
	#unset IFS

        echo
	endTimer
	rm -rf "${ADMIN_RUN}"
        echo -e "\nCompleted ${MSG} all specified Virtual Machines!\n"	
}
#-=-SSHRRRSVMS_FUNC_END-=-#

#-=-SNAPREMOVE_FUNC_START-=-#
snapremoveVMs () {
        CHOICE=$1

        case ${CHOICE} in
        1)
                QUEST="Creating snapshot"
		MSG="Creating snapshot"
                WARN_MSG="be snapshoted"
		if [ ! "${LEGACY_HOST}" == "1" ]; then
                        CMD="create"
                else
                        CMD="createsnapshot"
                fi
                ;;
        2)
                QUEST="Reverting snapshot"
		MSG="Reverting snapshot"
                WARN_MSG="reverting snapshot"
		if [ ! "${LEGACY_HOST}" == "1" ]; then
                	CMD="revert"
		else
			CMD="revertsnapshot"
		fi
                ;;
        esac

        echo

        if [ "${REMOTE_MODE}" -eq 0 ]; then
                cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}'

                echo -e "\n${QUEST} for the following ${VM_COUNT} Virtual Machine(s) y/n?"
                read userConfirm
                case $userConfirm in
                        yes|YES|y|Y)
                                echo "${QUEST} has been confirmed for the following ${VM_COUNT} Virtual machine(s)"
                                echo;;
                        no|NO|n|N)
                                echo "${QUEST} has been cancelled, script exiting"
				rm -rf "${ADMIN_RUN}"
                                exit;;
				*)
                                echo "Invalid input, please try again"
                                rm -rf "${ADMIN_RUN}"
                                exit;;
                esac
        fi
        startTimer
        #IFS=$'\n'
        for VM_NAME in `cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}' | sed 's/"//g'`;
        do
                VM_ID=`grep -E "\"${VM_NAME}\"" "${CLEANSED_VM_LIST}" | awk -F ";" '{print $1}' | sed 's/"//g'`
		if [ "${CHOICE}" == "1" ]; then
			if [ ! "${LEGACY_HOST}" == "1" ]; then
				${VMWARE_CMD} vmsvc/snapshot.${CMD} "${VM_ID}" "pristine" "SNAPSHOT_OF_${VM_NAME}_AFTER_ADMINISTRATIVE_CONFIGURATION-`date +%F-%H%M%S`" > /dev/null 2>&1
			else
				${VMWARE_CMD} -n -e "vmsvc/${CMD} ${VM_ID} pristine SNAPSHOT_OF_${VM_NAME}_AFTER_ADMINISTRATIVE_CONFIGURATION-`date +%F-%H%M%S`" > /dev/null 2>&1
			fi
		else
			if [ ! "${LEGACY_HOST}" == "1" ]; then
				${VMWARE_CMD} vmsvc/snapshot.${CMD} "${VM_ID}" 1 > /dev/null 2>&1
			else
				${VMWARE_CMD} -n -e "vmsvc/${CMD} ${VM_ID} 1" > /dev/null 2>&1
			fi
		fi
                echo "${MSG} : \"$VM_NAME\""
                sleep 2
        done
        #unset IFS

        echo
        endTimer
        rm -rf "${ADMIN_RUN}"
        echo -e "\nCompleted ${MSG} for all specified Virtual Machines!\n"
}
#-=-SNAPREMOVE_FUNC_END-=-#

#-=-PURGE_FUNC_START-=-#
purgeVMs () {
	echo
        if [ "${REMOTE_MODE}" -eq 0 ]; then
                cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}'

                echo -e "\nPurge the following ${VM_COUNT} Virtual Machine(s) y/n?"
                read userConfirm
                case $userConfirm in
                        yes|YES|y|Y)
                                echo "Purging has been confirmed for the following ${VM_COUNT} Virtual machine(s)"
                                echo;;
                        no|NO|n|N)
                                echo "Purging has been cancelled, script exiting"
				rm -rf "${ADMIN_RUN}"
                                exit;;
				*)
                                echo "Invalid input, please try again"
                                rm -rf "${ADMIN_RUN}"
                                exit;;
                esac
        fi
        startTimer
        #IFS=$'\n'
        for VM_NAME in `cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}' | sed 's/"//g'`;
        do
                VM_ID=`grep -E "\"${VM_NAME}\"" "${CLEANSED_VM_LIST}" | awk -F ";" '{print $1}' | sed 's/"//g'`
		if [ ! "${LEGACY_HOST}" == "1" ]; then
                	if ${VMWARE_CMD} vmsvc/power.getstate "${VM_ID}" | grep -E "Powered on" > /dev/null 2>&1; then
                        	echo "ERROR: \"${VM_NAME}\" is still powered on!"
               	 	else
                        	VM_DS=`grep -E "\"${VM_NAME}\"" "${ALL_VM_LIST}" | awk -F ";" '{print $3}' | sed 's/\[//;s/\]//;s/"//g'`
                        	VM_DIR=`grep -E "\"${VM_NAME}\"" "${ALL_VM_LIST}" | awk -F ";" '{print $4}' | sed 's/"//g'`
                        	VM_DIR=`dirname "${VM_DIR}"`
                        	RM_PATH="/vmfs/volumes/${VM_DS}/${VM_DIR}"
			fi
		else
			if ${VMWARE_CMD} -n -e "vmsvc/powerstate ${VM_ID}" | tail -1 | grep -E "Powered on" > /dev/null 2>&1; then
			       echo "ERROR: \"${VM_NAME}\" is still powered on!"
                        else
				case "${ESX_VER}" in 
					"3.0.0") SEARCH_STRING="/${VM_NAME}/${VM_NAME}.vmx";;
					"3.0.1"|"3.0.2"|"3.0.3") SEARCH_STRING="${VM_NAME}/${VM_NAME}.vmx";;
					*) SEARCH_STRING="${VM_NAME}/${VM_NAME}.vmx";;
				esac
				VM_DS=`grep -E "${SEARCH_STRING}" "${ALL_VM_LIST}" | awk '{print $3}' | sed 's/\[//;s/\]//g'`
				VM_DIR=`grep -E "${SEARCH_STRING}" "${ALL_VM_LIST}" | awk '{print $4}'`
				VM_DIR=`dirname "${VM_DIR}" | sed 's/\///g'`
				case "${ESX_VER}" in
                                        "3.0.0") VM_VMX="${VM_DS}/${VM_DIR}";;
                                        "3.0.1"|"3.0.2"|"3.0.3") VM_VMX="${VM_DS}/${VM_DIR}";;
                                        *) SEARCH_STRING="${VM_NAME}/${VM_NAME}.vmx";;
                        	esac	
				RM_PATH="/vmfs/volumes/${VM_VMX}"
			fi
		fi	

                if [[ ! -z "${VM_ID}" ]] && [[ ! -z "${VM_DS}" ]] && [[ ! -z "${VM_DIR}" ]] && [[ ! -z "${RM_PATH}" ]]; then
                	echo "Unregistering \"${VM_NAME}\" VM_ID=${VM_ID} and removing ${RM_PATH}"
			if [ ! "${LEGACY_HOST}" == "1" ]; then
				${VMWARE_CMD} vmsvc/unregister "${VM_ID}" > /dev/null 2>&1
			else
				${VMWARE_CMD} -n -e "vmsvc/unregister ${VM_ID}" > /dev/null 2>&1
			fi
			rm -rf "${RM_PATH}"
                else
                	echo "\"Unable to locate \"${VM_NAME}\""
                fi
        done
        #unset IFS

        echo
        endTimer
        rm -rf "${ADMIN_RUN}"
        echo -e "\nCompleted purge for all specified Virtual Machines!\n"
}
#-=-PURGE_FUNC_END-=-#

#-=-VNIC_FUNC_START-=-#
vnic () {
	if [ $# -eq 3 ]; then
                if echo $3 | egrep '^[0-9]*$' > /dev/null; then
                        NIC_ADAPTER=$3
                fi
        else
                NIC_ADAPTER=0
        fi

	HOST_PORTGROUP=${ADMIN_RUN}/host_portgroup.$$
	HOST_PG_DISPLAY=${ADMIN_RUN}/host_pg-display.$$

	vnet_counter=1
	SELECT_ARR=""
        #IFS=$'\n'
        echo -e "CHOICE\t\tVLAN ID\t\tPORTGROUP"
        echo "------------------------------------------"
	if [ ! "${LEGACY_HOST}" == "1" ]; then
        	${VMWARE_CMD} hostsvc/net/info | grep -E '(name|vlanId)' | grep -v vS | sed 's/,//;s/name =//;s/vlanId =//;s/^ *//;s/"//g' | sed -n '/^.*$/N; s/\n/%%%/p' | awk -F'%%%' '{print "#"$2"#"$1}' > "${HOST_PORTGROUP}"
		for PG in `cat ${HOST_PORTGROUP}`;
        	do
			VLANID=`echo ${PG} | awk -F "#" '{print $2}'`
			PORTGROUP=`echo ${PG} | awk -F "#" '{print $3}'`
                	echo -e "${vnet_counter}\t\t${VLANID}\t\t${PORTGROUP}" >> "${HOST_PG_DISPLAY}" 
                	vnet_counter=$(( ${vnet_counter} + 1 ))
        	done
	else
		${VMWARE_CMD} -n -e "hostsvc/net/info" | grep -E '(name|vlanId)' | grep -v vS | sed 's/,//;s/name =//;s/vlanId =//;s/^ *//;s/"//g' | sed -n '/^.*$/N; s/\n/%%%/p' | awk -F'%%%' '{print "#"$2"#"$1}' > "${HOST_PORTGROUP}"
		for PG in `cat ${HOST_PORTGROUP}`;
                do
			VLANID=`echo ${PG} | awk -F "#" '{print $2}'`
                        PORTGROUP=`echo ${PG} | awk -F "#" '{print $3}'`
                        echo -e "${vnet_counter}\t\t${VLANID}\t\t${PORTGROUP}" >> "${HOST_PG_DISPLAY}"
                        vnet_counter=$(( ${vnet_counter} + 1 ))
                done
	fi
	
        echo -e "${vnet_counter}\t\tQuit" >> "${HOST_PG_DISPLAY}"
        #unset IFS

	cat "${HOST_PG_DISPLAY}"
	echo -e "\nPlease select a portgroup to apply to the following Virtual Machine(s):"
	read selection

	VNET_SEL=`echo ${selection} | sed 's/ //g'`

        case ${VNET_SEL} in
                ${vnet_counter})
                        echo "Exiting..."
			rm -rf "${ADMIN_RUN}"
                        exit 0;;
                [1-9]*)
                        if ! echo ${VMFS_SEL} | egrep '^[0-9]*$' > /dev/null; then
                                echo "ERROR: Invalid character input..."
				rm -rf "${ADMIN_RUN}"
                                exit 1
                        fi
                        #validates the selection is between 1 and max # of lines
                        if [[ ${VNET_SEL} -ge 1 ]] && [[ ${VNET_SEL} -le ${vnet_counter} ]]; then
                                VM_PORTGROUP=`sed -n ${VNET_SEL}'p' "${HOST_PORTGROUP}" | awk -F "#" '{print $3}' | sed 's/[ \t]*$//'`
                        else
                                echo "ERROR: Invalid range selection..."
				rm -rf "${ADMIN_RUN}"
                                exit 1
                        fi
        esac

	if [ -z ${VM_PORTGROUP} ]; then
                echo "ERROR: Invalid character input..."
		rm -rf "${ADMIN_RUN}"
                exit 1
        fi

	echo
	if [ "${REMOTE_MODE}" -eq 0 ]; then
                cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}'

                echo -e "\nWould you like to update the Network configuration for \"eth${NIC_ADAPTER}\" to apply \"${VM_PORTGROUP}\" to the following ${VM_COUNT} Virtual Machine(s) y/n?"
                read userConfirm
                case $userConfirm in
                        yes|YES|y|Y)
                                echo "VM Network Portgroup update will take affect for the following ${VM_COUNT} Virtual machine(s)"
                                echo;;
                        no|NO|n|N)
                                echo "VM Network Portgroup update has been cancelled, script exiting"
				rm -rf "${ADMIN_RUN}"
                                exit;;
				*)
                                echo "Invalid input, please try again"
                                rm -rf "${ADMIN_RUN}"
                                exit;;
				*)
                                echo "Invalid input, please try again"
                                rm -rf "${ADMIN_RUN}"
                                exit;;
                esac
        fi
	startTimer
        #IFS=$'\n'
        for VM_NAME in `cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}' | sed 's/"//g'`;
        do
		VM_ID=`grep -E "\"${VM_NAME}\"" "${CLEANSED_VM_LIST}" | awk -F ";" '{print $1}' | sed 's/"//g'`
		if [ ! "${LEGACY_HOST}" == "1" ]; then
                	if ${VMWARE_CMD} vmsvc/power.getstate "${VM_ID}" | grep -E "Powered on" > /dev/null 2>&1; then
                        	echo "ERROR: \"${VM_NAME}\" is still powered on!"
                	else
                        	VM_DS=`grep -E "\"${VM_NAME}\"" "${ALL_VM_LIST}" | awk -F ";" '{print $3}' | sed 's/\[//;s/\]//;s/"//g'`
                        	VM_DIR=`grep -E "\"${VM_NAME}\"" "${ALL_VM_LIST}" | awk -F ";" '{print $4}' | sed 's/"//g'`
				VM_PATH="/vmfs/volumes/${VM_DS}/${VM_DIR}"
			fi
		else
			if ${VMWARE_CMD} -n -e "vmsvc/powerstate ${VM_ID}" | tail -1 | grep -E "Powered on" > /dev/null 2>&1; then
                               echo "ERROR: \"${VM_NAME}\" is still powered on!"
                        else
				case "${ESX_VER}" in
                                        "3.0.0") SEARCH_STRING="/${VM_NAME}/${VM_NAME}.vmx";;
                                        "3.0.1"|"3.0.2"|"3.0.3") SEARCH_STRING="${VM_NAME}/${VM_NAME}.vmx";;
                                esac
                                VM_DS=`grep -E "${SEARCH_STRING}" "${ALL_VM_LIST}" | awk '{print $3}' | sed 's/\[//;s/\]//g'`
                                VM_DIR=`grep -E "${SEARCH_STRING}" "${ALL_VM_LIST}" | awk '{print $4}'`
				case "${ESX_VER}" in
                                        "3.0.0") VM_VMX="${VM_DS}/${VM_DIR}";;
                                        "3.0.1"|"3.0.2"|"3.0.3") VM_VMX="${VM_DS}/${VM_DIR}";;
                        	esac
				VM_PATH="/vmfs/volumes/${VM_VMX}"
			fi	
		fi

                if [[ ! -z "${VM_ID}" ]] && [[ ! -z "${VM_DS}" ]] && [[ ! -z "${VM_DIR}" ]] && [[ ! -z "${VM_PATH}"  ]]; then
			OLD_PG=`grep ethernet${NIC_ADAPTER}.networkName "${VM_PATH}" | awk '{print $3}' | sed 's/"//g'`
			if [ ! -z "${OLD_PG}" ]; then
				sed -i 's/ethernet'${NIC_ADAPTER}'.networkName = ".*"/ethernet'${NIC_ADAPTER}'.networkName = "'${VM_PORTGROUP}'"/g' ${VM_PATH} > /dev/null 2>&1
				if [ ! "${LEGACY_HOST}" == "1" ]; then
					${VMWARE_CMD} vmsvc/reload ${VM_ID} > /dev/null 2>&1
				else
					${VMWARE_CMD} -n -e "vmsvc/reload ${VM_ID}" > /dev/null 2>&1
				fi
				echo "Completed configuring ${VM_NAME} from \"${OLD_PG}\" to \"${VM_PORTGROUP}\""
			else
				echo "Error configuring portgroup for ${VM_NAME}, \"eth${NIC_ADAPTER}\" may not exist or is invalid"
			fi
                else
                	echo "\"Unable to locate \"${VM_NAME}\""
                fi
	done
	#unset IFS

        echo
        endTimer
        rm -rf "${ADMIN_RUN}"
        echo -e "\nCompleted Network Configurations for all specified Virtual Machines!\n"
}
#-=-VNIC_FUNC_END-=-#

#-=-MAC_FUNC_START-=-#
mac () {
	OUTPUT_TYPE=${1}

	#generic case
	if [ "${OUTPUT_TYPE}" == "generic" ]; then
		ETH_ADAPTER=${2}
	fi

	#linux case
	if [ "${OUTPUT_TYPE}" == "nixdhcp" ]; then
		NETWORK_TYPE=${2}
        	HOST_TYPE=${3}
		ETH_ADAPTER=${4}

		#make sure we don't go over the 255 range
        	MAX=$(( ( ${VM_COUNT} - 1 ) + ${HOST_TYPE} ))
        	if [ ${MAX} -gt 255 ]; then
                	echo "Error: You have too many VMs to host assignment, max is 255"
                	rm -rf "${ADMIN_RUN}"
               		exit 1
        	fi
	fi

	#defaults 0
	echo ${ETH_ADAPTER} | egrep '^[0-3]' > /dev/null 2>&1
	if [[ $? -eq 1 ]] || [[ -z ${ETH_ADAPTER} ]]; then
		ETH_ADAPTER=0
	fi
	DHCP_OUTPUT=dhcp-eth${ETH_ADAPTER}-`date +%F-%H%M%S`
        touch "${DHCP_OUTPUT}" 

	startTimer
        #IFS=$'\n'
	for VM_NAME in `cat "${CLEANSED_VM_LIST}" | awk -F ";" '{print $2}' | sed 's/"//g'`;
	do
		if [ ! "${LEGACY_HOST}" == "1" ]; then
			VM_DS=`grep -E "\"${VM_NAME}\"" "${ALL_VM_LIST}" | awk -F ";" '{print $3}' | sed 's/\[//;s/\]//;s/"//g'`
                	VM_DIR=`grep -E "\"${VM_NAME}\"" "${ALL_VM_LIST}" | awk -F ";" '{print $4}' | sed 's/"//g'`
			VM_MAC=`grep ethernet${ETH_ADAPTER}.generatedAddress "/vmfs/volumes/${VM_DS}/${VM_DIR}" | grep -v "generatedAddressOffset" | awk '{print $3}' |  sed 's/"//g'`
		else
			case "${ESX_VER}" in
                                        "3.0.0") SEARCH_STRING="/${VM_NAME}/${VM_NAME}.vmx";;
                                        "3.0.1"|"3.0.2"|"3.0.3") SEARCH_STRING="${VM_NAME}/${VM_NAME}.vmx";;
                        esac
			VM_DS=`grep -E "${SEARCH_STRING}" "${ALL_VM_LIST}" | awk '{print $3}' | sed 's/\[//;s/\]//g'`
                	VM_DIR=`grep -E "${SEARCH_STRING}" "${ALL_VM_LIST}" | awk '{print $4}'`
			case "${ESX_VER}" in
                                        "3.0.0") VM_VMX="${VM_DS}/${VM_DIR}";;
                                        "3.0.1"|"3.0.2"|"3.0.3") VM_VMX="${VM_DS}/${VM_DIR}";;
                        esac
			VM_MAC=`grep ethernet${ETH_ADAPTER}.generatedAddress "/vmfs/volumes/${VM_VMX}" | grep -v "generatedAddressOffset" | awk '{print $3}' |  sed 's/"//g'`
		fi

		if [ ! -z "${VM_MAC}" ]; then
			if [ "${REMOTE_MODE}" -eq 0 ]; then
				if [ "${OUTPUT_TYPE}" == "generic" ]; then
					echo -e "${VM_NAME}\t${VM_MAC}" | sed 's/://g' >> "${DHCP_OUTPUT}"
				else	
					echo "host ${VM_NAME}        { hardware ethernet ${VM_MAC}; fixed-address ${NETWORK_TYPE}.${HOST_TYPE}; }" >> "${DHCP_OUTPUT}"
				fi
			else
				if [ "${OUTPUT_TYPE}" == "generic" ]; then
					echo -e "${VM_NAME}\t${VM_MAC}" | sed 's/://g'
				else
					echo "host ${VM_NAME}        { hardware ethernet ${VM_MAC}; fixed-address ${NETWORK_TYPE}.${HOST_TYPE}; }"
				fi
			fi
		else
			echo "WARNING: Unable to find eth${ETH_ADAPTER} for $VM_NAME!"
		fi
		HOST_TYPE=$(( ${HOST_TYPE} + 1 ))	
	done
        #unset IFS

	echo
        endTimer
	if [ -s ${DHCP_OUTPUT} ]; then
        	echo -e "\nCompleted \"${DHCP_OUTPUT}\" generation file for all specified Virtual Machines!\n"
        else
                echo -e "\nERROR: Unable to locate ethernet${ETH_ADAPTER} adapter or Virtual Machines specified in the file"
                rm ${DHCP_OUTPUT}
        fi
	rm -rf "${ADMIN_RUN}"
}
#-=-MAC_FUNC_END-=-#

####################
#		   #
# Start of Script  #
#		   #
####################

#prints UCSB Header
printHeader

if [ $# -lt 2 ]; then 
	printUsage
elif [[ "$1" == "remote" ]] && [[ -f /bin/vim-cmd ]]; then
	echo "Remote commands can not be executed on an ESXi hosts due to Dropbear SSH client limitation"
	exit 1
elif [[ "$1" == "remote" ]] && [[ ! $# -lt 4 ]]; then
	REMOTE_HOST=$2
	REMOTE_OP=$3
	USER_INPUT_FILE=$4
	REMOTE_SCRIPT=/tmp/remote_script.$$.sh
	REMOTE_FILE=/tmp/virtual_machine_input_file.$$

        if ! validate_ip ${REMOTE_HOST}; then
                echo "Invalid IP Address of \"${REMOTE_HOST}\" for ESX(i) Host"
                exit 1
        fi

	if [ ! -f "${USER_INPUT_FILE}" ]; then
		echo "Input file \"${USER_INPUT_FILE}\" does not exist"
		exit
	fi

	echo "#!/bin/bash" > "${REMOTE_SCRIPT}"

	echo "cat > ${REMOTE_FILE} << __VM_REMOTE_FILE__" >> "${REMOTE_SCRIPT}"
	cat "${USER_INPUT_FILE}" >> "${REMOTE_SCRIPT}"
	echo "__VM_REMOTE_FILE__" >> "${REMOTE_SCRIPT}"

	echo "REMOTE_MODE=1" >> "${REMOTE_SCRIPT}"

	sed -n '/^#-=-DEFAULT_START-=-#$/,/^#-=-DEFAULT_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
	sed -n '/^#-=-VALIDATE_IP_FUNC_START-=-#$/,/^#-=-VALIDATE_IP_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
	sed -n '/^#-=-STARTTIMER_FUNC_START-=-#$/,/^#-=-STARTTIMER_FUNC_END=-=#$/p' $0 >> "${REMOTE_SCRIPT}"
	sed -n '/^#-=-ENDTIMER_FUNC_START-=-#$/,/^#-=-ENDTIMER_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
	sed -n '/^#-=-CHECKHOSTTYPE_FUNC_START-=-#$/,/^#-=-CHECKHOSTTYPE_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
	sed -n '/^#-=-DUMPVMS_FUNC_START-=-#$/,/^#-=-DUMPVMS_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
	sed -n '/^#-=-VALIDATOR_FUNC_START-=-#$/,/^#-=-VALIDATOR_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
	case ${REMOTE_OP} in 
		start|shutdown|stop|reboot|reset|resume|suspend)
			sed -n '/^#-=-SSHRRRSVMS_FUNC_START-=-#$/,/^#-=-SSHRRRSVMS_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
			echo "validator 4 $# ${REMOTE_FILE}" >> "${REMOTE_SCRIPT}"
			awk 'BEGIN{KEY_STORE["start"]=1;KEY_STORE["shutdown"]=2;KEY_STORE["stop"]=3;KEY_STORE["reboot"]=4;KEY_STORE["reset"]=5;KEY_STORE["resume"]=6;KEY_STORE["suspend"]=7;print "startshutdownhaltrebootresetresumesuspendVMs "KEY_STORE["'${REMOTE_OP}'"]}' >> "${REMOTE_SCRIPT}"
			;;
		snap|revert)
			sed -n '/^#-=-SNAPREMOVE_FUNC_START-=-#$/,/^#-=-SNAPREMOVE_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
			echo "validator 4 $# ${REMOTE_FILE}" >> "${REMOTE_SCRIPT}"
                        awk 'BEGIN{KEY_STORE["snap"]=1;KEY_STORE["revert"]=2;print "snapremoveVMs "KEY_STORE["'${REMOTE_OP}'"]}' >> "${REMOTE_SCRIPT}"
			;;
		purge)
			sed -n '/^#-=-PURGE_FUNC_START-=-#$/,/^#-=-PURGE_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
			echo "validator 4 $# ${REMOTE_FILE}" >> "${REMOTE_SCRIPT}"
			echo "purgeVMs" >> "${REMOTE_SCRIPT}"
			;;
		mac)
			sed -n '/^#-=-MAC_FUNC_START-=-#$/,/^#-=-MAC_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
			echo "FLAG=mac" >> "${REMOTE_SCRIPT}"
			if [[ ! -z "${5}" ]] && [[ "${5}" == "generic" ]]; then
				echo "validator 4 $# ${REMOTE_FILE}" >> "${REMOTE_SCRIPT}"
				echo "mac $5 $6" >> "${REMOTE_SCRIPT}"
	                        #ethernet adapter selection
                        	if [ -z ${6} ]; then
                                	ETH_ADAPTER=0
                        	else
                                	ETH_ADAPTER=${6}
                       		fi
			fi

                	if [[ ! -z "${5}" ]] && [[ "${5}" == "nixdhcp" ]]; then
				echo "validator 7 $# ${REMOTE_FILE}" >> "${REMOTE_SCRIPT}"
				echo "mac $5 $6 $7 $8" >> "${REMOTE_SCRIPT}"
                       		#ethernet adapter selection
                        	if [ -z ${8} ]; then
                                	ETH_ADAPTER=0
                       		else
                                	ETH_ADAPTER=${8}
                        	fi
                	fi

        		DHCP_OUTPUT=dhcp-eth${ETH_ADAPTER}-`date +%F-%H%M%S`
			echo "Connecting to ${REMOTE_HOST} to extract MAC Addresses:"
			cat "${REMOTE_SCRIPT}" | ssh root@${REMOTE_HOST} "cat > ${REMOTE_SCRIPT}; chmod 755 ${REMOTE_SCRIPT}; ${REMOTE_SCRIPT}; rm ${REMOTE_FILE}; rm ${REMOTE_SCRIPT}" > /tmp/dhcpd.conf.$$
			#checks to see which output option was selected
			if [ "${5}" == "generic" ]; then
				grep "005056" /tmp/dhcpd.conf.$$ > "${DHCP_OUTPUT}"
			else
				grep "hardware ethernet" /tmp/dhcpd.conf.$$ > "${DHCP_OUTPUT}"
			fi
                       	rm /tmp/dhcpd.conf.$$
                        rm "${REMOTE_SCRIPT}"

			if [ -s ${DHCP_OUTPUT} ]; then
				echo -e "\nCompleted \"${DHCP_OUTPUT}\" generation file for all specified Virtual Machines!\n"
			else
				echo -e "\nERROR: Unable to locate ethernet${ETH_ADAPTER} adapter or Virtual Machines specified in the file"
				rm ${DHCP_OUTPUT}
			fi
        		exit
			;;
		vnic)
			sed -n '/^#-=-VNIC_FUNC_START-=-#$/,/^#-=-VNIC_FUNC_END-=-#$/p' $0 >> "${REMOTE_SCRIPT}"
			echo "validator 2 $# ${REMOTE_FILE}" >> "${REMOTE_SCRIPT}"
			echo "vnic $3" >> "${REMOTE_SCRIPT}"
			echo "Sending remote script to ${REMOTE_HOST}"
			cat "${REMOTE_SCRIPT}" | ssh root@${REMOTE_HOST} "cat > ${REMOTE_SCRIPT}; chmod 755 ${REMOTE_SCRIPT}"
			echo "Executing remote script on ${REMOTE_HOST}"
			ssh root@${REMOTE_HOST} "${REMOTE_SCRIPT}; rm ${REMOTE_FILE}; rm ${REMOTE_SCRIPT}"
			rm "${REMOTE_SCRIPT}"
			exit
			;;
		*)printUsage;;
	esac
	echo "Executing remote operation: \"${REMOTE_OP}\" on host: ${REMOTE_HOST} with the following specified Virtual Machines:"
	echo -e "\n#####################################"
	cat "${USER_INPUT_FILE}" | sed '/^$/d' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//'
	echo -e "#####################################\n"
	echo "OPERATION WILL BE EXECUTED IMMEDIATELY ONCE AUTHENTICATION ON REMOTE HOST SUCCEEDS!"
	echo "Would you like to continue y/n?"
	read userConfirm
	case $userConfirm in
                y|Y)
			cat "${REMOTE_SCRIPT}" | ssh root@${REMOTE_HOST} "cat > ${REMOTE_SCRIPT}; chmod 755 ${REMOTE_SCRIPT}; ${REMOTE_SCRIPT} ; rm ${REMOTE_FILE}; rm ${REMOTE_SCRIPT}"
			;;
                n|N)
                        echo "Remote operation cancelled, script exiting"
			;;
        esac
	rm "${REMOTE_SCRIPT}"
	exit
else
	FLAG=$1
fi

#checks to see which option was selected by the user
case $FLAG in
	start)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 1;;
	shutdown)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 2;;	
	stop)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 3;;
	reboot)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 4;;
	reset)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 5;;
	resume)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 6;;
	suspend)
		validator 2 $# "${2}"
		startshutdownhaltrebootresetresumesuspendVMs 7;;
	snap)	
		validator 2 $# "${2}"
		snapremoveVMs 1;;
	revert)
		validator 2 $# "${2}"
		snapremoveVMs 2;;
	purge)
		validator 2 $# "${2}"
		purgeVMs;;
	mac)
		#handle linux or generic
		if [[ ! -z "${3}" ]] && [[ "${3}" == "generic" ]]; then
			validator 3 $# "${2}"
                	mac "${3}" "${4}"
		elif [[ ! -z "${3}" ]] && [[ "${3}" == "nixdhcp" ]]; then
			validator 5 $# "${2}"
			mac "${3}" "${4}" "${5}" "${6}"
		else
			echo "Output selection invalid, please select \"generic\" or \"nixdhcp\""
                	rm -rf "${ADMIN_RUN}"
                	exit 1
		fi
		;;
	vnic)
		validator 1 $# "${2}"
		vnic "${3}";;
	*)
		printUsage;;
esac
