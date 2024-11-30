
DROP TABLE IF EXISTS user_presents_pending;

CREATE TABLE `user_presents_pending` (
	`id` bigint NOT NULL AUTO_INCREMENT,
	`user_id` bigint NOT NULL comment 'ユーザID',
	`sent_at` bigint NOT NULL comment 'プレゼント送付日時',
	`item_type` int(1) NOT NULL comment 'アイテム種別',
	`item_id` int NOT NULL comment 'アイテムID',
	`amount` int NOT NULL comment 'アイテム数',
	`present_message` varchar(255) comment 'プレゼントメッセージ',
	`created_at` bigint NOT NULL,
	`updated_at` bigint NOT NULL,
	`deleted_at` bigint DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX userid_idx (`user_id`),
	INDEX idx_user_presents_user_id_deleted_at_created_at (user_id, deleted_at, created_at DESC, id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;
ALTER TABLE user_presents_pending AUTO_INCREMENT=100000000001;

INSERT INTO
	user_presents_pending
SELECT
	*
FROM
	user_presents
WHERE
	deleted_at IS NULL;
