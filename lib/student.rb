require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    # Creates the "students" table if it doesn't exist
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    # Drops the "students" table if it exists
    sql = <<-SQL
      DROP TABLE IF EXISTS students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      insert
    end
  end

  def insert
    # Inserts a new row into the "students" table
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    self
  end

  def update
    # Updates the existing row in the "students" table
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    self
  end

  def self.create(name:, grade:)
    # Creates a new student and saves it to the database
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    # Creates a new instance of Student with data from a database row
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    # Finds a student by name in the database
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1;
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
end
