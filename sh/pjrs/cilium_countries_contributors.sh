#!/bin/bash
STOP=1 PRINT_ITEM=1 PRINT_DO=1 ITEMS='United States@@Germany@@China@@India@@United Kingdom@@France@@Switzerland@@Canada@@Netherlands@@Australia@@Russian Federation@@Japan@@Spain@@Poland@@Sweden@@Norway@@Czech Republic' DO='clear@@CUMULATIVE=2016-08-01 SKIPDT=1 PG_DB=cilium ./sh/rep.sh months country_contributors {{country}} ##@@cat out.csv' ./sh/for_each_do.sh
