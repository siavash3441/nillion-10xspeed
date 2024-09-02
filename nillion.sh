#!/bin/bash

echo ""
echo "Follow: https://x.com/zhiwani"
read -p "Have you followed https://github.com/siavash3441 on X? (y/Y to proceed): " FOLLOWED

if [[ ! "$FOLLOWED" =~ ^[yY]$ ]]; then
    echo ""
    echo "Please follow @siavash3441 on X before proceeding."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo ""
    echo "Docker not found. Installing Docker..."
    sudo apt update && sudo apt install -y curl && \
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sudo sh get-docker.sh
    sudo usermod -aG docker ${USER} && su - ${USER} -c "groups"
else
    echo ""
    echo "Docker is already installed."
fi

if [ -d "nillion" ]; then
    echo ""
    echo "'nillion' directory found. Removing..."
    sudo rm -r "nillion"
else
    echo ""
    echo "'nillion' directory not found."
fi
sudo apt update && sudo apt install -y jq bc
echo ""
echo "Stopping and removing any running containers with the name 'nillion'..."
docker ps | grep nillion | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep nillion | awk '{print $1}' | xargs -r docker rm

echo ""
echo "Pulling NILLION docker image..."
docker pull nillion/retailtoken-accuser:latest

echo ""
echo "Creating directory and running Docker container to initialize..."
mkdir -p nillion/accuser && \
docker run -v "$(pwd)/nillion/accuser:/var/tmp" nillion/retailtoken-accuser:latest initialise

SECRET_FILE=~/nillion/accuser/credentials.json
if [ -f "$SECRET_FILE" ]; then
    ADDRESS=$(jq -r '.address' "$SECRET_FILE")
    echo ""
    echo "Request nillion faucet (https://faucet.testnet.nillion.com) to your accuser wallet address: $ADDRESS"
    echo ""

    read -p "Have you requested the faucet to the accuser wallet? (y/Y to proceed): " FAUCET_REQUESTED1
    if [[ "$FAUCET_REQUESTED1" =~ ^[yY]$ ]]; then
        echo ""
        echo "Now visit: https://verifier.nillion.com/verifier"
        echo "Connect a new Keplr wallet."
        echo "Request faucet to the nillion address : https://faucet.testnet.nillion.com"
        echo ""

        read -p "Have you requested faucet to your Keplr wallet? (Y/y to proceed): " FAUCET_REQUESTED2
        if [[ "$FAUCET_REQUESTED2" =~ ^[yY]$ ]]; then
            read -p "Input your Keplr wallet's nillion address: " KEPLR
            echo ""
            echo "Input the following information on the website: https://verifier.nillion.com/verifier"
            echo "Address: $ADDRESS"
            echo "Public Key: $(jq -r '.pub_key' "$SECRET_FILE")"
            echo ""

            read -p "Have you done this? (Y/y to proceed): " address_submitted
            if [[ "$address_submitted" =~ ^[yY]$ ]]; then
                echo ""
                echo "Save this Private Key in safe place: $(jq -r '.priv_key' "$SECRET_FILE")"
                echo ""
                read -p "Have you saved the private key in a safe place? (y/Y to proceed): " private_key_saved
                if [[ "$private_key_saved" =~ ^[yY]$ ]]; then
                    echo ""
                    echo "Running Docker container with accuse command..."
                    sudo docker run -v "$(pwd)/nillion/accuser:/var/tmp" nillion/retailtoken-accuser:latest accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com/" --block-start "$(curl -s "https://testnet-nillion-api.lavenderfive.com/cosmos/tx/v1beta1/txs?query=message.sender='$KEPLR'&pagination.limit=20&pagination.offset=0" | jq -r '[.tx_responses[] | select(.tx.body.memo == "AccusationRegistrationMessage")] | sort_by(.height | tonumber) | .[-1].height | tonumber - 5' | bc)"
                else
                    echo ""
                    echo "Please save the private key and try again."
                fi
            else
                echo ""
                echo "Please complete the submission and try again."
            fi
        else
            echo ""
            echo "Please request the faucet to your Keplr wallet and try again."
        fi
    else
        echo ""
        echo "Please request the faucet and try again."
    fi
else
    echo ""
    echo "credentials.json file not found. Ensure the initialization step completed successfully."
fi
