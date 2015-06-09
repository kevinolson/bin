#!/usr/bin/env csh
# The -f means the csh does not load up anything

# This is a very generic shell script with some simple examples
#
# ARGVs :
#   $argv - an array ( aka wordlist )
#  or 
#   $1 through $n ( unlimited )
#
# VARIABLE :
#   set name = "Henri"
#   $?name - tests if variable is defined
#
# ARRAY :
#   ( a b )
#
# FOREACH : 
#   foreach name (wordlist)
#       ...do whatever
#   end
#
# IF ELSIF ELSE :  
#   if (something) then
#       ...something
#   else if (something 2) then
#       ...something 2
#   else
#       ...the else result
#   endif
#
# WHILE LOOP :
#   while (something)
#       ...do something until we are done
#   end
#
# SWITCH STATEMENT :
#   switch ( EXPR )
#       case STRINGPATTERN1:
#           ...
#           ...
#       breaksw
#       case STRINGPATTERN2:
#           ...
#           ...
#       breaksw
#       default:
#           ...
#           ...
#   endsw
