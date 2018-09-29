PROMPT  Create a network ACE for APEX
declare
    l_acl_path varchar2(4000);
    l_apex_schema varchar2(100);
begin
    for c1 in (select schema
                 from sys.dba_registry
                where comp_id = 'APEX') loop
        l_apex_schema := c1.schema;
    end loop;
    sys.dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(privilege_list => xs$name_list('connect'),
        principal_name => l_apex_schema,
        principal_type => xs_acl.ptype_db));
    commit;
end;
/

PROMPT Create APEX Instance Admin User
begin
    apex_util.set_security_group_id( 10 );
    apex_util.create_user(
        p_user_name => 'ADMIN',
        p_email_address => 'admin@example.org',
        p_web_password => 'admin',
        p_developer_privs => 'ADMIN' );
    apex_util.create_user(
        p_user_name => 'TEST',
        p_email_address => 'test@example.org',
        p_web_password => 'test',
        p_developer_privs => 'ADMIN' );

    -- see https://docs.oracle.com/database/apex-5.1/AEAPI/Available-Parameter-Values.htm#AEAPI248

    apex_instance_admin.set_parameter('ACCOUNT_LIFETIME_DAYS', 999);
    apex_instance_admin.set_parameter('MAX_SESSION_IDLE_SEC', 0);
    apex_instance_admin.set_parameter('MAX_SESSION_LENGTH_SEC', 0);
    apex_instance_admin.set_parameter('EXPIRE_FND_USER_ACCOUNTS', 'N');
    apex_instance_admin.set_parameter('LOGIN_THROTTLE_DELAY', 0);
    apex_instance_admin.set_parameter('PASSWORD_HISTORY_DAYS', 0);
    apex_instance_admin.set_parameter('STRONG_SITE_ADMIN_PASSWORD', 'N');

    apex_instance_admin.set_parameter('WORKSPACE_PROVISION_DEMO_OBJECTS', 'N');
    apex_instance_admin.set_parameter('WORKSPACE_WEBSHEET_OBJECTS', 'N');

    apex_instance_admin.set_parameter('REJOIN_EXISTING_SESSIONS', 'Y');


    apex_util.set_security_group_id( null );
    commit;
end;
/


