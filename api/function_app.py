import azure.functions as func
import json

app = func.FunctionApp()

@app.route(route="GetCounter", auth_level=func.AuthLevel.ANONYMOUS)
@app.cosmos_db_input(arg_name="inputDocument", 
                     database_name="ResumeDB", 
                     container_name="Counter", 
                     id="1", 
                     partition_key="1", 
                     connection="CosmosDbConnectionString")
@app.cosmos_db_output(arg_name="outputDocument", 
                      database_name="ResumeDB", 
                      container_name="Counter", 
                      connection="CosmosDbConnectionString")
def GetCounter(req: func.HttpRequest, inputDocument: func.DocumentList, outputDocument: func.Out[func.Document]) -> func.HttpResponse:
    
    if not inputDocument:
        doc = {"id": "1", "count": 1}
    else:
        doc = inputDocument[0].to_dict()
        # Increment the visitor count
        doc['count'] += 1
    outputDocument.set(func.Document.from_dict(doc))
    
    return func.HttpResponse(
        json.dumps({"count": doc['count']}),
        mimetype="application/json",
        status_code=200
    )