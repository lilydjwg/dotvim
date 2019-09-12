def some_heavy_query
  execute <<-SQL
    select * from users where something = 'other';
  SQL

  File.write 'script.sh', <<-EOF
    #! /bin/sh
    ls | grep 'something'
  EOF
end
