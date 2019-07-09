WHENEVER SQLERROR EXIT failure
-- Install file for interaction-free installation of apex
--
-- @see http://joelkallman.blogspot.de/2017/05/apex-and-ords-up-and-running-in2-steps.html
--
-- Usage: @apex_install_helper.sql sysaux sysaux temp /i/
--
-- @version 0.0.3-dev   


define TBLS_APEX      = '&1'
define TBLS_FILES     = '&2'
define TBLS_TEMP      = '&3'
define IMG_DIR        = '&4'

define APEX_PUBLIC_USER_PW = '&5'


PROMPT  Install APEX
@apexins &TBLS_APEX &TBLS_FILES &TBLS_TEMP &IMG_DIR

set define on

PROMPT  Unlock the APEX_PUBLIC_USER account
alter user apex_public_user identified by &APEX_PUBLIC_USER_PW account unlock;

PROMPT  Configure APEX REST
@apex_rest_config_core.sql ./ &APEX_PUBLIC_USER_PW &APEX_PUBLIC_USER_PW

commit; 

@apex_service_config 

exit
