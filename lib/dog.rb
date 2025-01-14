require 'pry'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize (id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, 
        breed = ?
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create (attributes)
        dog = self.new(attributes)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE dogs.id = ?"

        row = DB[:conn].execute(sql, id)[0]
            self.new_from_db(row)
    end


    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"

        row = DB[:conn].execute(sql, name)[0]
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          attributes = {name: name, breed: breed}
          dog = self.create(attributes)
        end
        dog
    end

end