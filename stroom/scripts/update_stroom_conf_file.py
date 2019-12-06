from utils import get_inventory, get_service_fqdn, get_db_fqdn, regex_replace
import sys

def prepend_line(path, line):
    file = open(path, "r+")
    content = file.read()
    file.seek(0,0)
    file.write(line.rstrip('\r\n') + '\n' + content)


def replace_host_ip_line(fqdn, conf_file_path):
    regex_replace(conf_file_path, r"IP_ADDRESS", fqdn)

    
def replace_db_host_ip_line(fqdn, conf_file_path):
    # TODO port should not be hard coded
    regex_replace(conf_file_path, r"^(stroom\.jdbcDriverUrl=.*?//).*?:\d+", r"\1" + fqdn + ":3306")
    regex_replace(conf_file_path, r"^(stroom.statistics.sql.jdbcDriverUrl=.*?//).*?:\d+", r"\1" + fqdn + ":3306")

    
def main():
    path_to_stack = sys.argv[1]
    # env_file_path = f"{path_to_stack}/latest/config/stroom_core.env"
    conf_file_path = "{}/latest/config/stroom.conf".format(path_to_stack)
    inventory = get_inventory()
    fqdn = get_service_fqdn(inventory)
    db_fqdn = get_db_fqdn(inventory)

    # Order is important here
    replace_db_host_ip_line(db_fqdn, conf_file_path)
    replace_host_ip_line(fqdn, conf_file_path)


main()
