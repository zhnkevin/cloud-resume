"""
Lambda function for the cloud resume AI chatbot.
Queries a Bedrock Knowledge Base with the user's question
and returns a generated response based on resume context.
"""

import json
import os
import boto3

# set up bedrock client and pull config from env vars
bedrock = boto3.client("bedrock-agent-runtime", region_name=os.environ["AWS_REGION_NAME"])
KB_ID = os.environ["KNOWLEDGE_BASE_ID"]
REGION = os.environ["AWS_REGION_NAME"]
MODEL = f"arn:aws:bedrock:{REGION}::foundation-model/amazon.nova-lite-v1:0"

# Prompt template for the KB — $search_results$ and $query$ are replaced by Bedrock with the retrieved chunks and user question
PROMPT = (
    "Answer questions about Kevin Zheng's resume using the search results below.\n"
    "Kevin's LinkedIn: https://www.linkedin.com/in/zhnkevin/\n"
    "Kevin's GitHub: https://github.com/zhnkevin\n"
    "If asked for links or contact info, provide these URLs.\n\n"
    "Search results:\n$search_results$\n\n"
    "Question: $query$"
)


def lambda_handler(event, context):
    # parse the question from the request body
    body = json.loads(event.get("body", "{}"))
    question = body.get("question", "")

    # Query the knowledge base and generate a response
    resp = bedrock.retrieve_and_generate(
        input={"text": question},
        retrieveAndGenerateConfiguration={
            "type": "KNOWLEDGE_BASE",
            "knowledgeBaseConfiguration": {
                "knowledgeBaseId": KB_ID,
                "modelArn": MODEL,
                "generationConfiguration": {
                    "promptTemplate": {"textPromptTemplate": PROMPT}
                },
            },
        },
    )

    # Send back the answer with CORS headers for the frontend
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps({"answer": resp["output"]["text"]}),
    }
