# Avaya Aura Template

This project assists in creating a new Avaya Aura deployment on AWS. A script (import-ova.sh) is used to assist on OVA image to AMI conversion. OVA images for the required roles (Avaya Communication Manager, should be stored in an Amazon S3 bucket.

## Requirements

### Terminal Access

Console access with BASH 3.2 or newer. You can use AWS CloudShell with the proper credentials.
Proper credentials to list functions, pull configuration, upload code and change runtime configuration.

### jq

https://stedolan.github.io/jq/


## Importing OVA files

Importing OVA files leverages Amazon EC2 import image tool. Importing images requires a vmimport role with a vmie as a trusted service and S3 Bucket access. 

The template import-role-template.yaml assists in creating this role. To deplyo, go to the Cloud Formation console, deploy the import-role-template.yaml file specifying the bucket where the OVA images are stored.

Next, from a CloudShell terminal in the region you are working, provide execution permissions for the script:

`chmod +x import-ova.sh`

The following parameters are available for the script:

    -i: Initiate OVA import job.

    -s: Check for import job.

    -b: S3 bucket where file is stored. (required for import job) 

    -f: S3 filekey of the OVA. (required for import job)

    -r: region where bucket and AMI will be created.

    -h: List command options.

### Usage

Importing MyImage.OVA from S3 bucket 'MyBucket' in Virginia 
    `./import-ova.sh -r us-east-1 -b MyBucket -f MyImage.OVA -i`

Checking on import task MyImage.OVA in Virginia 
    `./import-ova.sh -r us-east-1 -f MyImage.OVA -s`


### Aura Deployment Template

The avayaaura.json template provides a starting point for deployments, including:

 1. A Virtual Private Cloud.
 2. 6 subnets(Private, Public and Management in 2 availability zones).
 3. Security Groups for bastion access, management, SBC public, SBC private, SBC management, System Manager, Communication Manager and Phones domains.
 4. Internet Gateway.
 5. Routes for Internet Access.
 6. Amazon EC2 instances for SBC, EMS, System Manager, Session Manager and Communication Manager.
 7. Windows Bastion host for remote access.

 Deploy from the Cloud Formation console, fill in for the required roles. Use AMI IDs for the required roles.

