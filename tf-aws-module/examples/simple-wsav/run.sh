config_script_input_file="../../../scripts/python_scripts/api_config_mgmt/device_info.py"
current_dir=$(pwd)
echo "Started ... "
echo "terraform init ... "
terraform init
echo "terraform plan ... "
terraform plan
echo "terraform apply ... "
if ! terraform apply; then
    echo "ERROR"
else
    echo "Initializing Configuration ... "
    terraform output > $config_script_input_file
    cd ../../../scripts/python_scripts/api_config_mgmt/
    echo "Starting - Update configuration script ... "
    python config_mgmt.py 
    echo "Completed - Configuration script"
fi
