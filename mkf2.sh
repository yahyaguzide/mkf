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

filetype="";
filename="";

comments="";
# NOTE: the subsitute Comment Character could be used in the Comment!
cchar_sub="~";
cchar="";

author="Yahya Guezide";
date=$(date '+%d.%m.%Y');

if [ -z "$1" ] # if only mkf is entered without arguments print out info file
then
    # This will get the path of our script so we can Read mkf-info outside of 
    # directory mkf
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	cat $DIR/mkf-info.txt;
else
    # flag to read in the filename
    _readName=0;
    for var in "$@"
    do
        # read in the filename
        if [ "$_readName" -eq "1" ]
        then
            filename=$var;
            _readName=0;
            continue;
        fi

        case $var in 
        -*)
            _readName=1;
            filetype=$var;
    		filetype=$(echo "$filetype" | sed -e "s/-//");

            # set cchar wich is just one string that indicates 
            # a commentar, example this is a commentar in bash
            # indicated via # or in c via // 
            case $filetype in "c"|"cc"|"cpp"|"h")
                cchar="//";;
            "sh"|"py"|*)
                cchar="#";;
            "asm")
                cchar=";";;
            esac;;
        *)
            if [ -z "$cchar" ]
            then
 #               comments="$comments""$cchar_sub $var\n";
 #           else
                comments="$comments""$cchar $var\n";
            fi
            ;;
        esac
    done
    if [ ! -z "$comments" ] 
    then 
        comments=$comments$cchar;
        # NOTE: the trim operation is not exchanging the whole string but only the first char
#        comments=$(echo $comments | tr $cchar_sub "$cchar") # change substitued Chars to the right one
    fi
    _filename=$(echo $filename | tr a-z A-Z) # to uppercase

    echo "filetype:" "$filetype";
    echo "filename:" "$filename";
    echo "comments:" "$comments";

    if [ -z "$filetype" ]
    then
        errmsg "No filetype given";
    fi
    [ "$_error" -eq "0" ] &&    if [ ! -e $templatePath/$filetype ] # look if a template for this fileytpe is in .templates
                            	then
                                    errmsg "There is no such Temlpate";
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
