import boto3
import pandas as pd 
import json
import time
import base64

column_names = [
    "Name",
    "Platform",
    "Year_of_Release",
    "Genre",
    "Publisher",
    "NA_Sales",
    "EU_Sales",
    "JP_Sales",
    "Other_Sales",
    "Global_Sales",
    "Critic_Score",
    "Critic_Count",
    "User_Score",
    "User_Count",
    "Developer",
    "Rating"
]

data_obj = {
    "Name": "",
    "Platform": "",
    "Year_of_Release": "",
    "Rating": "",
    "User_Score": ""
}
data_path = "./video_game_sales_dataset/video_game_sales.csv" 
data = pd.read_csv(
    data_path,
    delimiter=",",
    names=column_names
)

print(data[["Name", "Platform"]].sample(5))

print(data[data.Platform == "DS"].sample(5))

# Connect to AWS Kinesis Firehose
firehose_client = boto3.client('firehose', region_name='us-east-1')

for index, row in data.iterrows():
    if index != 0:
        data_obj["Name"] = row["Name"]
        data_obj["Platform"] = row["Platform"]
        data_obj["Year_of_Release"] = row["Year_of_Release"]
        data_obj["Rating"] = row["Rating"]
        data_obj["User_Score"] = row["User_Score"]
        
        print("Processing...")
        print(data_obj)
        print("\n\n\n\n\n")

        print("JSON game string base 64 encoded")
        json_game_string = json.dumps(data_obj)
        json_game_string_enc = json_game_string
        print(str(base64.b64encode(json_game_string_enc.encode('utf-8'))))
        firehose_player_response = firehose_client.put_record(
            DeliveryStreamName='tf-stream-ingest',
            Record={
                'Data': json_game_string
            }
        )
        print(firehose_player_response)
        time.sleep(2)