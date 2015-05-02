drop procedure if exists insert_node;
delimiter //
create_procedure insert_node(in _name varchar(255), in _description varchar(255), 
	in _slug varchar(255), in _parent_id int)
begin
	select count(*) into @row_count from nodetree;
	if @row_count = 0 then
		insert into nodetree(name, description, slug, lft, rgt) 
			values(_name, _description, _slug, 1, 2);
	else
		if isnull(_parent_id) then
			select @lft := max(rgt) + 1, @rgt := max(rgt) + 2 from nodetree;
			insert into nodetree(name, description, slug, lft, rgt) 
				values(_name, _description, _slug, @lft, @rgt);
		else
			select @subject_lft := lft, @subject_rgt := rgt 
				from nodetree where id = _parent_id;
			select count(*) into @children_count from nodetree 
				where lft > @subject_lft and rgt < @subject_rgt;
			if @children_count = 0 then
				update nodetree set rgt = rgt + 2 where rgt >= @subject_rgt;
				update nodetree set lft = lft + 2 where lft > @subject_lft;
				insert into nodetree(name, description, slug, lft, rgt) 
					values(_name, _description, _slug, @subject_lft + 1, @subject_lft + 2);
			else
				select @max_lft := max(lft), @max_rgt := max(rgt) from nodetree 
					where lft > @subject_lft and rgt < @subject_rgt;
				update nodetree set lft = lft + 2 where lft > @max_lft;
				update nodetree set rgt = rgt + 2 where rgt > @max_rgt;
				insert into nodetree(name, description, slug, lft, rgt) 
					values(_name, _description, _slug, @max_lft + 2, @max_rgt + 2);
			end if;
		end if;
	end if;
end//
delimiter ;
drop procedure if exists delete_node;
delimiter //
create_procedure delete_node(in _id int)
begin
	select @subject_lft := lft, @subject_rgt := rgt from nodetree where id = _id;
	delete from nodetree where lft >= @subject_lft and rgt <= @subject_rgt;
	set @x := @subject_rgt - @subject_lft + 1;
	update nodetree set lft = lft- @x where lft > @subject_lft;
	update nodetree set rgt = rgt- @x where rgt > @subject_rgt;
end//
delimiter ;
