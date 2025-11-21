class ConvertEncryptedPasswordToPasswordDigest < ActiveRecord::Migration[7.1]
  def up
    # Rename the existing encrypted_password column
    rename_column "users.user", :encrypted_password, :password_digest
  end
  def down
    # Rename the password_digest column back to encrypted_password
    rename_column "users.user", :password_digest, :encrypted_password
  end
end
