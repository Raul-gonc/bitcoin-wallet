defmodule Bitcoinwallet.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    # Adiciona índice para otimizar buscas por símbolo
    create_if_not_exists index(:transactions, [:symbol])
    
    # Adiciona índice para otimizar buscas por data
    create_if_not_exists index(:transactions, [:date])
    
    # Adiciona índice composto para otimizar consultas de balanço por usuário e símbolo
    create_if_not_exists index(:transactions, [:user_id, :symbol])
  end
end
