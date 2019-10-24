#!/bin/bash


#######################################
# Version 2.0 
# of the famous, grandous program
# mk -MotherFricken- f
#######################################

_error=0;
errmsg(){
	echo "error:" "$1";
    _error=1;
}

templatePath="/home/$USER/.templates";

template="";
filetype="";
filename="";

comments="";
cchar="";

author="Yahya Guezide";
date=$(date '+%d.%m.%Y');

if [ -z "$1" ] # if only mkf is entered without arguments print out info file
then
	cat mkf-info.txt;
else
    # flag to read in arguments
    _read=0;
    for var in "$@"
    do
        # read and save agrument
        [ ! "$_read" -eq "0" ] && case "$_read" in
			"1")
				_read=0;
            	template=$var;
            	continue;;
			"2")
				_read=0;
				filename=$var;
				continue;;
			#*)
			#	_read=0;;
		esac

        case $var in 
        --template)
			_read=1;;	
        -*)
            _read=2;
            filetype=$var;
    		filetype=$(echo "$filetype" | sed -e "s/-//");

            # set cchar wich is just one character that indicates 
            # a commentar, example this is a commentar in bash
            # indicated via # or in c via // 
            case $filetype in 
            	"c"|"cc"|"cpp"|"h")
                cchar="//";;
            "sh"|"py"|*)
                cchar="#";;
            "asm")
                cchar=";";;
            esac;;
        *)
            comments="$comments""$cchar $var\n";;
        esac
    done
    [ ! -z "$comments" ] && comments=$comments$cchar;
    _filename=$(echo $filename | tr a-z A-Z) # to uppercase

	[ ! -z $template ] && echo "template:" "$template";
    echo "filetype:" "$filetype";
    echo "filename:" "$filename";
    echo "comments:" "$comments";

    if [ -z "$filetype" ]
    then
        errmsg "No filetype given";
    fi
    [ "$_error" -eq "0" ] &&    if [ -z "$template" ]
								then
    								[ ! -e $templatePath/$filetype ] && errmsg "There is no such Temlpate";
    							else
    								[ ! -e  $templatePath/$template ] && errmsg "Template not found";
                                fi
    [ "$_error" -eq "0" ] &&    if [ -z "$filename" ] # no filename was given print out errmsg
                                then
                            		errmsg "no file name given";
                                fi 
    [ "$_error" -eq "0" ] &&    if [ -e $PWD/$filename.$filetype ]
                                then
                                    errmsg "file $filename.$filetype already exists";
                                fi

    if [ "$_error" -eq "0" ]
    then
		if [ -z "$template" ]
		then
        	cp $templatePath/$filetype $PWD/$filename.$filetype;
		else
			cp $templatePath/$template $PWD/$filename.$filetype;
		fi
        sed -i "s/\[NAME\]/$filename/g" $PWD/$filename.$filetype;
        sed -i "s/\[_NAME\]/$_filename/g" $PWD/$filename.$filetype;
        # because '//' is used in comments sed gets confused and throws
        # an error, to solve this i used @, this means @ should not be used
        # in any comments
        sed -i "s@\[COMMENT\]@$comments@g" $PWD/$filename.$filetype; 
        sed -i "s/\[AUTHOR\]/$author/g" $PWD/$filename.$filetype; 
        sed -i "s/\[DATE\]/$date/g" $PWD/$filename.$filetype; 
	fi
fi
