/*
 *  Copyright (C) 2010 Luka Sostaric. MySQL Node Tree is
 *  distributed under the terms of the GNU General Public
 *  License.
 *
 *  This program is free software: You can redistribute AND/or modIFy
 *  it under the terms of the GNU General Public License, as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *  Program Information
 *  -------------------
 *  Program Name: MySQL Node Tree
 *  Module Name: Node Tree
 *  External Components Used: None
 *  Required Modules: None
 *  License: GNU GPL
 *
 *  Author Information
 *  ------------------
 *  Full Name: Luka Sostaric
 *  E-mail: luka@lukasostaric.com
 *  Website: www.lukasostaric.com
 */
DROP PROCEDURE IF EXISTS insert_node;
DELIMITER //
CREATE PROCEDURE insert_node(IN _name VARCHAR(255), IN _description VARCHAR(255), 
    IN _slug VARCHAR(255), IN _parent_id INT)
BEGIN
    SELECT COUNT(*) INTO @row_count FROM nodetree;
    IF @row_count = 0 THEN
        INSERT INTO nodetree(name, description, slug, lft, rgt) 
            VALUES(_name, _description, _slug, 1, 2);
    ELSE
        IF ISNULL(_parent_id) THEN
            SELECT @lft := MAX(rgt) + 1, @rgt := MAX(rgt) + 2 FROM nodetree;
            INSERT INTO nodetree(name, description, slug, lft, rgt) 
                VALUES(_name, _description, _slug, @lft, @rgt);
        ELSE
            SELECT @subject_lft := lft, @subject_rgt := rgt 
                FROM nodetree WHERE id = _parent_id;
            SELECT COUNT(*) INTO @children_count FROM nodetree 
                WHERE lft > @subject_lft AND rgt < @subject_rgt;
            IF @children_count = 0 THEN
                UPDATE nodetree set rgt = rgt + 2 WHERE rgt >= @subject_rgt;
                UPDATE nodetree set lft = lft + 2 WHERE lft > @subject_lft;
                INSERT INTO nodetree(name, description, slug, lft, rgt) 
                    VALUES(_name, _description, _slug, @subject_lft + 1, @subject_lft + 2);
            ELSE
                SELECT @max_lft := MAX(lft), @max_rgt := MAX(rgt) FROM nodetree 
                    WHERE lft > @subject_lft AND rgt < @subject_rgt;
                UPDATE nodetree set lft = lft + 2 WHERE lft > @max_lft;
                UPDATE nodetree set rgt = rgt + 2 WHERE rgt > @max_rgt;
                INSERT INTO nodetree(name, description, slug, lft, rgt) 
                    VALUES(_name, _description, _slug, @max_lft + 2, @max_rgt + 2);
            END IF;
        END IF;
    END IF;
END//
DELIMITER ;
DROP PROCEDURE IF EXISTS delete_node;
DELIMITER //
CREATE PROCEDURE delete_node(IN _id INT)
BEGIN
    SELECT @subject_lft := lft, @subject_rgt := rgt FROM nodetree WHERE id = _id;
    DELETE FROM nodetree WHERE lft >= @subject_lft AND rgt <= @subject_rgt;
    SET @x := @subject_rgt - @subject_lft + 1;
    UPDATE nodetree set lft = lft- @x WHERE lft > @subject_lft;
    UPDATE nodetree set rgt = rgt- @x WHERE rgt > @subject_rgt;
END//
DELIMITER ;
