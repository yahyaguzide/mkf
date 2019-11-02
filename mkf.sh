#!/bin/bash

errmsg(){
	echo "error:" "$1";
}

templatePath="/home/$USER/.templates"

filetype=""
filename=""

comments=""
cchar=""

author="Yahya Guezide"
date=$(date '+%d.%m.%Y')

if [ -z "$1" ] # if only mkf is entered without arguments print out info file
then
	cat mkf-info.txt;
else
	if [ -z "$2" ] # no filename was given print out errmsg
	then
		errmsg "no file name given";
	else
		filetype=$1;
		filename=$2;

		filetype=$(echo "$filetype" | sed -e "s/-//");

        # set cchar wich is just one character that indicates 
        # a commentar, example this is a commentar in bash
        # indicated via # or in c via // 

        case $filetype in "c"|"cc"|"cpp"|"h")
            cchar="//";;
        "sh"|"py"|*)
            cchar="#";;
        "asm")
            cchar=";";;
        esac

		if [ ! -e $templatePath/$filetype ] # look if a template for this fileytpe is in .templates
		then
			errmsg "There is no such Temlpate";
		else
			if [ -e $PWD/$filename.$filetype ]
			then
				errmsg "file $filename.$filetype already exists";
			else
				
                index=0;
                for var in "$@"
                do
                    if [ "$index" -gt "1" ]
                    then
                        comments="$comments""$cchar $var\n";
                    else
                        ((index=index+1));
                    fi
                done
                [ ! -z "$comments" ] && comments=${comments::-2};
                _filename=$(echo $filename | tr a-z A-Z) # to uppercase

				cp $templatePath/$filetype $PWD/$filename.$filetype;
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
	fi
fi	


