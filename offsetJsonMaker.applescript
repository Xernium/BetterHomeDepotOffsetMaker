# We have both RELEASE_ARM_ and Marijuan_ARM_ .....

set krnver_list to {"Darwin Kernel Version 15.0.0: Fri Oct 2 14:07:07 PDT 2015; root:xnu-3248.10.42~4/", "Darwin Kernel Version 15.0.0: Fri Nov 13 16:08:07 PST 2015; root:xnu-3248.21.2~1/", "Darwin Kernel Version 15.0.0: Wed Dec 9 22:19:38 PST 2015; root:xnu-3248.31.3~2/", "Darwin Kernel Version 15.4.0: Fri Feb 19 13:54:52 PST 2016; root:xnu-3248.41.4~28/", "Darwin Kernel Version 15.5.0: Mon Apr 18 16:44:07 PDT 2016; root:xnu-3248.50.21~4/", "Darwin Kernel Version 15.6.0: Mon Jun 20 20:10:21 PDT 2016; root:xnu-3248.60.9~1/"}

set fw_list to {"9.1", "9.2", "9.2.1", "9.3", "9.3.1", "9.3.2", "9.3.3", "9.3.4"}
set fw_count to length of fw_list
set fw_krnl_vers to {1, 2, 3, 4, 4, 5, 6, 6}
set offset_count to 13

# iPad 2's except 2,4 & iPhone 4S: S5L8940 -- A5
# iPhone 5 & iPhone 5C: S5L8950 -- A6 
# iPad 3: S5L8945 -- A5X
# iPad 4: S5L8955 -- A6X
# iPad mini & iPod touch 5G & iPad2,4 : S5L8942 -- A5 REV A
# We need some devices to query the offsets from, one for each processor:

set target_device_list to {"iPhone4,1", "iPhone5,1", "iPad3,1", "iPad3,4", "iPad2,4"}
set processor_list to {"S5L8940X", "S5L8950X", "S5L8945X", "S5L8955X", "S5L8942X"}
set device_count to length of target_device_list

set jsonpath to (quoted form of POSIX path of (get path to home folder) & "/Desktop/offsets.json") as string

# Set the file first
do shell script ("echo {  >& " & jsonpath)
# All set?

repeat with current_device from 1 to device_count by 1
	repeat with current_fw from 1 to fw_count by 1
		do shell script ("curl http://wall.supplies/offsets/" & (item current_device of target_device_list) & "-" & (item current_fw of fw_list))
		set response to result
		#display dialog response with title "TRS"
		set resp_paragraph to paragraphs of response
		
		if (count paragraphs of response) is not offset_count then
			do shell script ("echo " & (quoted form of ("Error! The following offsets failed to be correctly recieved: " & (item current_device of target_device_list) & "-" & (item current_fw of fw_list) & ", Recieved " & (count paragraphs of response) & " but expected " & offset_count & " offsets!")) & " >> " & ((quoted form of POSIX path of (get path to home folder)) & "/Desktop/mkoffsets.log"))
		else
			set eb_c_kernel_string to ((item (item current_fw of fw_krnl_vers) of krnver_list) & "RELEASE_ARM_" & item current_device of processor_list) as string
			set running_c_kernel_string to ((item (item current_fw of fw_krnl_vers) of krnver_list) & "Marijuan_ARM_" & item current_device of processor_list) as string
			do shell script {"echo " & (quoted form of ("  \"" & eb_c_kernel_string & "\":")) & " >> " & jsonpath}
			do shell script {"echo " & (quoted form of ("   [\"" & item 1 of resp_paragraph & "\",")) & " >> " & jsonpath}
			repeat with current_offset from 2 to (offset_count - 1) by 1
				do shell script {"echo " & (quoted form of ("    \"" & item current_offset of resp_paragraph & "\",")) & " >> " & jsonpath}
			end repeat
			do shell script {"echo " & (quoted form of ("    \"" & item 13 of resp_paragraph & "\"],")) & " >> " & jsonpath}
			
			do shell script {"echo " & (quoted form of ("  \"" & running_c_kernel_string & "\":")) & " >> " & jsonpath}
			do shell script {"echo " & (quoted form of ("   [\"" & item 1 of resp_paragraph & "\",")) & " >> " & jsonpath}
			repeat with current_offset from 2 to (offset_count - 1) by 1
				do shell script {"echo " & (quoted form of ("    \"" & item current_offset of resp_paragraph & "\",")) & " >> " & jsonpath}
			end repeat
			if ((current_device is equal to device_count) and (current_fw is equal to fw_count)) then
				do shell script {"echo " & (quoted form of ("    \"" & item 13 of resp_paragraph & "\"]")) & " >> " & jsonpath}
				do shell script ("echo }  >> " & jsonpath)
			else
				do shell script {"echo " & (quoted form of ("    \"" & item 13 of resp_paragraph & "\"],")) & " >> " & jsonpath}
			end if
		end if
	end repeat
end repeat



