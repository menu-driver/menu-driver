namespace :dynamodb do

  desc "Setup for DynamoDB.  You should only need this once."
  task :setup do
    puts system <<-EOC
      docker network create menu-driver
    EOC
    puts system <<-EOC
      docker run -d -v "$PWD":/dynamodb_local_db -p 8000:8000 --network menu-driver --name dynamodb amazon/dynamodb-local
    EOC
    Rake::Task['dynamodb:create_tables'].execute
  end

  desc "Reset the DynamoDB installation."
  task :reset do
    system('docker stop dynamodb; docker rm dynamodb')
  end
  
  desc "Run local DynamoDB."
  task :start do
    system('docker start dynamodb')
  end

  desc "Create DynamoDB tables."
  task :create_tables do
    puts system <<-EOC
      aws dynamodb create-table --endpoint-url http://localhost:8000 --table-name menus --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
    EOC
  end
  
  desc "Delete DynamoDB tables."
  task :delete_tables do
    puts system <<-EOC
      aws dynamodb delete-table --endpoint-url http://localhost:8000 --table-name menus
    EOC
  end

  desc "Scan DynamoDB 'menus' table."
  task :scan_menus do
    puts system <<-EOC
      aws dynamodb scan --endpoint-url http://localhost:8000 --table-name menus
    EOC
  end

end