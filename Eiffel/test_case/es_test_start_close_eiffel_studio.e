note
	description: "[
					Test for simply start Eiffel Studio, then close Eiffel Studio.
																					]"
	date: "$Date$"
	revision: "$Revision$"

class
	ES_TEST_START_CLOSE_EIFFEL_STUDIO

inherit
	EQA_TEST_SET

feature -- Access

	test_one
			-- First UI test of Eiffel Studio
		local

			l_kernel: EB_KERNEL
			l_env: EV_ENVIRONMENT
		do
			create l_kernel.make
			fill_test_procedures
			eqa_ui.start
			create l_env
			l_env.application.launch
		end

feature {NONE} -- Implementation

	fill_test_procedures
			-- Filling testing procedures
		do
			eqa_ui.add_test_procedure (agent eqa_ui.button_click ("start dialig cancel"))
			eqa_ui.add_test_procedure (agent eqa_ui.window_close_button_click ("developemnt window"))
			eqa_ui.add_test_procedure (agent eqa_ui.button_click ("Discardable prompt Yes"))
		end

	eqa_ui: EQA_UI_FUNCTIONS
			-- UI testing helpers
		once
			create Result
		end
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
