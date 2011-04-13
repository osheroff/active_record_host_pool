require 'delegate'

# the ConnectionProxy sits between user-code and a real connection and says "I expect to be on this database"
# for each call to the connection.  upon executing a statement, the connection will switch to that database.
module ActiveRecordHostPool
  class ConnectionProxy < Delegator
    def initialize(cx, database)
      super(cx)
      @cx = cx
      @database = database
    end

    def __getobj__
      @cx._host_pool_current_database = @database
      @cx
    end

    def unproxied
      @cx
    end

    # this helps along folks who want to muck around with our delegatee's methods
    def class
      @cx.class
    end
  end
end


