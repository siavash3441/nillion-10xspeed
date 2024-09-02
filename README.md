# nillion-10xspeed

<h2 align=center>Nillion Verifier Node Guide</h2>

- You can use either VPS or Ubuntu on Windows
- Make sure that you have a nillion address, if u have not, you can install [Keplr](https://chromewebstore.google.com/detail/keplr/dmkamcknogkgcdfhhbddcghachkejeap) and create a nillion address
- Use the below command to start the nillion verifier
```bash
wget -q https://raw.githubusercontent.com/siavash3441/nillion-10xspeed/main/nillion.sh && chmod +x nillion.sh && ./nillion.sh
```
- You will see `Registered : true` after 20 mins
- And your node will start sending secret to Nillion after 50 mins


<h2 align=center> Frequently Asked Questions </h2>

- **How to check whether it true or false**

Use this command to check the docker container ID of nillion
```bash
docker ps
```
Copy the `CONTAINER_ID` of nillion docker container
Now replace the `CONTAINER_ID` in the below command and then execute the below command
```bash
docker logs CONTAINER_ID -n 500 | grep "Registered"
```

- **How to check : how many secrets has been sent to nillion?**

Use this command to check the docker container ID of nillion
```bash
docker ps
```
Copy the `CONTAINER_ID` of nillion docker container

Now replace the `CONTAINER_ID` in the below command and then execute the below command

```bash
docker logs CONTAINER_ID -n 500 | grep "Secret stores Found"
```

- **Issue : Secret found 0 but registered True**

Press `Ctrl + C` to stop it then use the below command
```bash
docker ps
```
[ Copy the docker container ID of nillion]

Then, re-run using the below commands, make sure to replace `CONTAINER_ID` in the below command with the CONTAINER ID you copied in the above step👇

```bash
docker restart CONTAINER_ID
```
```bash
sudo docker run -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:latest accuse --rpc-endpoint "https://nillion-testnet.rpc.kjnodes.com" --block-start "$(curl -s https://testnet-nillion-rpc.lavenderfive.com/abci_info | jq -r '.result.response.last_block_height')"
```

- **Issue : Error from tendermint rpc/ Operation timed out**

Don't forget to replace `ENTER_YOUR_KEPLR_WALLET_NILLION_ADDRESS` in the below command
```bash
sudo docker run -v "$(pwd)/nillion/accuser:/var/tmp" nillion/retailtoken-accuser:latest accuse --rpc-endpoint "https://nillion-testnet.rpc.kjnodes.com" --block-start "$(curl -s "https://testnet-nillion-api.lavenderfive.com/cosmos/tx/v1beta1/txs?query=message.sender='ENTER_YOUR_KEPLR_WALLET_NILLION_ADDRESS'&pagination.limit=20&pagination.offset=0" | jq -r '[.tx_responses[] | select(.tx.body.memo == "AccusationRegistrationMessage")] | sort_by(.height | tonumber) | .[-1].height | tonumber - 5' | bc)"
```

- **I am running nillion verifier on my Ubuntu (Windows), After closing the PC when I will reopen  my PC to run verifier node which command I need to paste ?**
```bash
sudo docker run -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:latest accuse --rpc-endpoint "https://nillion-testnet.rpc.kjnodes.com" --block-start "$(curl -s https://testnet-nillion-rpc.lavenderfive.com/abci_info | jq -r '.result.response.last_block_height')"
```
Or
```bash
sudo docker run -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:latest accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com/" --block-start "$(curl -s https://testnet-nillion-rpc.lavenderfive.com/abci_info | jq -r '.result.response.last_block_height')"
```
