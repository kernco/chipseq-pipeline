#!/bin/bash -l

PE=false

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        --broad)
            BROAD="$2"
            shift
            ;;
        --narrow)
            NARROW="$2"
            shift
            ;;
        --input)
            INPUT="$2"
            shift
            ;;
        --assembly)
            ASSEMBLY="$2"
            shift
            ;;
        --genome_size)
            GSIZE="$2"
            shift
            ;;
        --paired_end)
            PE=true
            ;;
        *)
            ;;
    esac
    shift
done

PIPELINE_DIR=`dirname $0`;

if [ PE ]; then 
    MAKEFILE=$PIPELINE_DIR/chipseq-pe.makefile
else 
    MAKEFILE=$PIPELINE_DIR/chipseq.makefile
fi

for broadmark in ${BROAD//,/ }
do
    make -f $MAKEFILE ${broadmark}_broad_report.txt MARK=$broadmark INPUT=$INPUT ASSEMBLY=$ASSEMBLY GSIZE=$GSIZE 
done

for narrowmark in ${NARROW//,/ }
do
    make -f $MAKEFILE ${narrowmark}_narrow_report.txt MARK=$narrowmark INPUT=$INPUT ASSEMBLY=$ASSEMBLY GSIZE=$GSIZE
done
