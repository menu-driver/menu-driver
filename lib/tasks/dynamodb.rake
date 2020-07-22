namespace :dynamodb do

  desc "Setup for DynamoDB.  You should only need this once."
  task :setup do
    command =  <<-EOC
      docker network create menu-driver
    EOC
    puts 'running: ' + command
    puts system command
    command = <<-EOC
      docker run -d -v "$PWD":/dynamodb_local_db -p 8000:8000 --network menu-driver --name dynamodb amazon/dynamodb-local
    EOC
    puts 'running: ' + command
    puts system command
    Rake::Task['dynamodb:create_tables'].execute
  end

  desc "Reset the DynamoDB installation."
  task :reset do
    command = 'docker stop dynamodb; docker rm dynamodb'
    puts 'running: ' + command
    system(command)
  end
  
  desc "Run local DynamoDB."
  task :start do
    command = 'docker start dynamodb'
    puts 'running: ' + command
    system(command)
  end

  desc "Create DynamoDB tables."
  task :create_tables do
    command = <<-EOC
      aws dynamodb create-table --endpoint-url http://localhost:8000 --table-name MenusTable --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
    EOC
    puts 'running: ' + command
    puts system command
  end
  
  desc "Delete DynamoDB tables."
  task :delete_tables do
    command = <<-EOC
      aws dynamodb delete-table --endpoint-url http://localhost:8000 --table-name MenusTable
    EOC
    puts 'running: ' + command
    puts system command
  end

  desc "Scan DynamoDB 'MenusTable' table."
  task :scan_menus do
    command = <<-EOC
      aws dynamodb scan --endpoint-url http://localhost:8000 --table-name MenusTable
    EOC
    puts 'running: ' + command
    puts system command
  end

end