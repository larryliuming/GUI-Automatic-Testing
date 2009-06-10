note
	description: "Summary description for {EAQ_UI_FUNCTIONS}."
	date: "$Date$"
	revision: "$Revision$"

class
	EQA_UI_FUNCTIONS

inherit
	ANY
		redefine
			default_create
		end

	EQA_TEST_SET
		undefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- <Precursor>
		local
--			l_env: EV_ENVIRONMENT
		do
			create timer_actions.make (50)

			-- Vision2's uncaught exception actions will block testing tool to received the exception
--			create l_env
--			l_env.application.uncaught_exception_actions.extend (agent on_vision2_exception)
		end

feature {EQA_TEST_SET} -- UI helpers

	button_click (a_identifer_name: STRING)
			-- Click on a button
		require
			a_name_not_void: a_identifer_name /= Void
		do
			if attached {EV_BUTTON} find_widget_with_name (a_identifer_name) as l_button then
				click_button (l_button)
			else
				quit (False, "can't find button with name: " + a_identifer_name)
			end

			add_next_timer_action
		end

	menu_click (a_identifer_name: STRING)
			-- Click on a menu
		require
			not_void: a_identifer_name /= Void
		do
			check not_implemented: False end
		end

	window_close_button_click (a_window_identifier: STRING)
			-- Click on the close button of a window
		require
			not_void: a_window_identifier /= Void
		do
			if attached {EV_WINDOW} find_widget_with_name (a_window_identifier) as l_window then
				click_window_close_button (l_window)
			else
				quit (False, "can't find window with name: " + a_window_identifier)
			end

			add_next_timer_action
		end

	check_button_text (a_identifier_name: STRING; a_correct_text: STRING)
			-- Check button's text
		require
			a_name_not_void: a_identifier_name /= Void
			a_correct_text_not_void: a_correct_text /= Void
		do
			if attached {EV_BUTTON} find_widget_with_name (a_identifier_name) as l_button then
				if not (l_button.text ~ (a_correct_text)) then
					quit (False, "button's text not correct. " + a_identifier_name + " " + a_correct_text + " " + l_button.text)
				end
			else
				quit (False, "can't find button with name: " + a_identifier_name)
			end

			add_next_timer_action
		end

	check_grid_item_text (a_grid_identifer_name, a_grid_item_identifier_name: STRING; a_correct_text: STRING)
			-- Check grid item's text
		require
			not_void: a_grid_identifer_name /= Void
			not_void: a_grid_item_identifier_name /= Void
			not_void: a_correct_text /= Void
		do
			check not_implemented: False end
		end

feature {EQA_TEST_SET} -- Command

	start
			-- Start UI testing
		require
			not_started: not is_testing
		do
			timer_actions.start
			create timeout
			timeout.actions.extend_kamikaze (next_timer_action)
			timeout.set_interval (5000)
			is_testing := True
		ensure
			is_testing: is_testing
			created: timeout /= Void
		end

	timeout: EV_TIMEOUT
		-- Timer used for UI Testing

	add_test_procedure (a_procedure: PROCEDURE [ANY, TUPLE])
			-- Add `a_procedure' for testing
			-- `a_procedure' will be executed
		require
			not_void: a_procedure /= Void
			not_started: not is_testing
		do
			timer_actions.extend (a_procedure)
		ensure
			added: old timer_actions.count + 1 = timer_actions.count
		end

feature -- Query

	is_testing: BOOLEAN
			-- If testing now?

feature {NONE} -- Idle actions

	timer_actions: ARRAYED_LIST [PROCEDURE [ANY, TUPLE]]
			-- Idle actions for testing

	next_timer_action: PROCEDURE [ANY, TUPLE]
			-- ** Key testing process here **
			-- Result void means no more testing procedures
		do
			if not timer_actions.after  then
				Result := timer_actions.item
				timer_actions.forth
			else
				quit (True, void)
			end
		end

	add_next_timer_action
			-- Add next timer action
		local
			l_next_action: like next_timer_action
		do
			l_next_action := next_timer_action
			if l_next_action /= Void then
				add_once_timer_action (l_next_action)
			else
				-- Void means no more testing procedure left
			end
		end

	add_once_timer_action (a_agent: PROCEDURE [ANY, TUPLE])
			-- Add `a_agent' to timer actions
		require
			a_seconds_valid: a_agent /= Void
		do
			timeout.actions.extend_kamikaze (a_agent)
		end

feature {NONE} -- Implementations

	quit (a_success: BOOLEAN; a_tag: STRING)
			-- Quit
		local
			l_tag: STRING
		do
			if a_tag /= Void then
				l_tag := a_tag
			else
				l_tag := "Vision2 testing failed"
			end
			if not a_success then
				assert (l_tag, False)
			end
		end

--	on_vision2_exception (a_exception: EXCEPTION)
--			--
--		local
--			l_tag: STRING
--			l_env: EV_ENVIRONMENT
--		do
--			l_tag := a_exception.meaning
--			if a_exception.message /= Void then
--				l_tag := " " + a_exception.message
--			end

--			assert (l_tag, False)

--			create l_env
--			l_env.application.destroy
--		end

feature {NONE} -- Implementation

	find_widget_with_name (a_identifier_name: STRING): EV_WIDGET
			-- Find button with identifier name which is `a_name'
		require
			not_void: a_identifier_name /= Void
		local
			l_env: EV_ENVIRONMENT
			l_windows: LINEAR [EV_WINDOW]
		do
			from
				create l_env
				l_windows := l_env.application.windows
				l_windows.start
			until
				l_windows.after or Result /= Void
			loop
				Result := find_widget_recursive (l_windows.item, a_identifier_name)

				l_windows.forth
			end
		end

	find_widget_recursive (a_top_level_widget: EV_WIDGET; a_identifier_name: STRING): EV_WIDGET
			-- Find widget which identifier name is `a_identifier_name' recursivly in `a_top_level_widget'
		require
			a_widget_not_void: a_top_level_widget /= Void
			a_widget_name_not_void: a_identifier_name /= Void
		local
			l_items: LINEAR [EV_WIDGET]
		do
			if a_top_level_widget.identifier_name.is_equal (a_identifier_name) then
				Result := a_top_level_widget
			else
				if attached {EV_CONTAINER} a_top_level_widget as lt_container then
					from
						l_items := lt_container.linear_representation
						l_items.start
					until
						l_items.after or Result /= Void
					loop
						Result := find_widget_recursive (l_items.item, a_identifier_name)
						l_items.forth
					end
				end
			end
		end

	click_button (a_button: EV_BUTTON)
			-- Click on `a_button'
		require
			a_button_not_void: a_button /= Void
		local
			l_screen: EV_SCREEN
		do
			create l_screen
			l_screen.set_pointer_position (a_button.screen_x + a_button.width // 2, a_button.screen_y + a_button.height // 2)
			check_if_button_under_pointer (a_button)
			l_screen.fake_pointer_button_click ({EV_POINTER_CONSTANTS}.left)
		end

	click_window_close_button (a_window: EV_WINDOW)
			-- Click close button of `a_window'
		require
			not_void: a_window /= Void
		local
			l_screen: EV_SCREEN
		do
			create l_screen
			l_screen.set_pointer_position (a_window.screen_x + a_window.width - 5, a_window.screen_y + 5)
			check_if_window_under_pointer (a_window)
			l_screen.fake_pointer_button_click ({EV_POINTER_CONSTANTS}.left)
		end

	click_tool_bar_button (a_sd_tool_bar_identifier: STRING; a_button_identifer: STRING)
			-- Click {SD_TOOL_BAR}'s button
		require
			not_void: a_sd_tool_bar_identifier /= Void
			not_void: a_button_identifer /= Void
		local
		do
			check not_implemented: False end
		end

	click_grid_item (a_grid_identifier_name: STRING; a_grid_item_identifer: STRING)
			-- Click on a grid item
		require
			not_void: a_grid_identifier_name /= Void
			not_void: a_grid_item_identifer /= Void
		do
			check not_implemented: False end
		end

	check_if_window_under_pointer (a_window: EV_WINDOW)
			-- Check if `a_window' under pointer position
		require
			not_void: a_window /= Void
		do
--			check not_implemented: False end
		end

	check_if_button_under_pointer (a_button: EV_BUTTON)
			-- Check if `a_button' under pointer position
		require
			a_button_not_void: a_button /= Void
		local
			l_screen: EV_SCREEN
		do
			create l_screen
			if {l_button: EV_BUTTON} l_screen.widget_at_mouse_pointer then
				check a_button_under_pointer: l_button = a_button end
			else
				check a_button_not_exists: False end
			end
		end

invariant
	not_void: timer_actions /= Void

note
	copyright: "Copyright (c) 1984-2009, Eiffel Software"
	license: "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options: "http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
