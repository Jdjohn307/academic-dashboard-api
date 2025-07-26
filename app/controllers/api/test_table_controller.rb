module Api
  class TestTableController < BaseController
    def index
      render jsonapi: TestTable.all
    end

    def create
      test_table = TestTable.new(test_table_params)

      if test_table.save
        render jsonapi: test_table, status: :created
      else
        render jsonapi: { errors: test_table.errors}, status: :unprocessable_entity
      end
    end

    private

    def test_table_params
      params.require(:test_table).permit(:name)
    end
  end
end