# Solc version tests

The scripts require installed [Brownie](https://eth-brownie.readthedocs.io/en/stable/install.html) testing framework.


Test can be executed by running:
```
brownie run run.py --silent
```

After successfull execution following table must be printed to the stdout:

```
                           	0.8.0   	0.7.4 	0.6.12	0.5.17	0.4.26
address_convetion          	OK      	OK    	OK    	OK    	OK
asm_returndata             	OK      	OK    	OK    	OK    	OK
asm_returndata_expand      	CHECK   	CHECK 	CHECK 	CHECK 	CHECK
asm_returndata_shrink      	OK      	OK    	OK    	OK    	OK
dirty_calldata             	REVERTED	OK    	OK    	OK    	OK
returndata_asm_shrink      	CHECK   	CHECK 	CHECK 	CHECK 	CHECK
returndata_convertion_dirty	REVERTED	CHECK 	CHECK 	CHECK 	CHECK
returndata_div             	REVERTED	CHECK2	CHECK2	CHECK2	CHECK2
returndata_expand          	OK      	OK    	OK    	OK    	OK
returndata_shrink          	OK      	OK    	OK    	OK    	OK
returndata_sum             	REVERTED	CHECK2	CHECK2	CHECK2	CHECK2
uint_shrink                	OK      	OK    	OK    	OK    	OK
uint_shrink_expand         	CHECK   	CHECK 	CHECK 	CHECK 	CHECK
```
