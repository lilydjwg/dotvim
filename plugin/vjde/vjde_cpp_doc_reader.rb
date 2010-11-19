
module Vjde #{{{1
		def Vjde.get_loction_line(fun,file1) #{{{2
			file = File.expand_path(file1)
			return nil unless File.exists?(file)
			flen = File.size(file)
			len = fun.length

			st = 0
			ed = flen
			index = (ed-st)/2

			f = File.open(file)
			l = ''
			last = -1
			ll =''
			while 1
				f.seek(index)
				ll = f.gets
				if ll==nil
					break
				end
				l = f.gets
				if l == nil
					l = ll
					break
				end
				if index == last
					l = nil
					break
				else 
					len = l.index(' ')-1
					cpr = (fun<=>l[0..len])
					last = index
					if cpr<0
						ed = index
						index = (ed-st)/2+st
					elsif cpr>0
						st = index
						index = (ed-st)/2+st
					else 
						break
					end
					if index==0
						f.seek(0)
						l = f.gets
						break
					end
				end
			end
			f.close()
			return l
		end #}}}2
	class CppDocReader #{{{2
		attr_accessor :file
		attr_accessor :pstart
		attr_accessor :pend
		RE_TAG=/<(\/*\w+)\s*[^>]*>/
		REP_PATTERNS={'code'=>'<span foreground="blue">','/code'=>'</span>',
				'em'=>'<b>','/em'=>'</b>','h3'=>'<big>','/h3'=>'</big>',
				'a'=>'<u>','/a'=>'</u>'}

		GLIB_DOC_MAP={
		}
		GTK_DOC_MAP= { #{{{4
			'gtk_window_group'=>'GtkWindowGroup.html',
			'gtk_window'=>'GtkWindow.html',
			'gtk_widget'=>'GtkWidget.html',
			'gtk_vseparator'=>'GtkVSeparator.html',
			'gtk_vscrollbar'=>'GtkVScrollbar.html',
			'gtk_vscale'=>'GtkVScale.html',
			'gtk_vruler'=>'GtkVRuler.html',
			'gtk_vpaned'=>'GtkVPaned.html',
			'gtk_viewport'=>'GtkViewport.html',
			'gtk_vbutton_box'=>'GtkVButtonBox.html',
			'gtk_vbox'=>'GtkVBox.html',
			'gtk_uimanager'=>'GtkUIManager.html',
			'gtk_tree_view'=>'GtkTreeView.html',
			'gtk_tree_store'=>'GtkTreeStore.html',
			'gtk_tree_sortable'=>'GtkTreeSortable.html',
			'gtk_tree_selection'=>'GtkTreeSelection.html',
			'gtk_tree_model'=>'GtkTreeModel.html',
			'gtk_tree_item'=>'GtkTreeItem.html',
			'gtk_tree_view_column'=>'GtkTreeViewColumn.html',
			'gtk_tree_model_sort'=>'GtkTreeModelSort.html',
			'gtk_tree_model_filter'=>'GtkTreeModelFilter.html',
			'gtk_tree'=>'GtkTree.html',
			'gtk_tooltips'=>'GtkTooltips.html',
			'gtk_toolbar'=>'GtkToolbar.html',
			'gtk_tool_item'=>'GtkToolItem.html',
			'gtk_tool_button'=>'GtkToolButton.html',
			'gtk_toggle_button'=>'GtkToggleButton.html',
			'gtk_toggle_action'=>'GtkToggleAction.html',
			'gtk_toggleTool_button'=>'GtkToggleToolButton.html',
			'gtk_tips_query'=>'GtkTipsQuery.html',
			'gtk_text_view'=>'GtkTextView.html',
			'gtk_text_tag'=>'GtkTextTag.html',
			'gtk_text_mark'=>'GtkTextMark.html',
			'gtk_text_buffer'=>'GtkTextBuffer.html',
			'gtk_textTag_table'=>'GtkTextTagTable.html',
			'gtk_text'=>'GtkText.html',
			'gtk_tearoff_menu_item'=>'GtkTearoffMenuItem.html',
			'gtk_table'=>'GtkTable.html',
			'gtk_style'=>'GtkStyle.html',
			'gtk_statusbar'=>'GtkStatusbar.html',
			'gtk_spin_button'=>'GtkSpinButton.html',
			'gtk_socket'=>'GtkSocket.html',
			'gtk_size_group'=>'GtkSizeGroup.html',
			'gtk_settings'=>'GtkSettings.html',
			'gtk_separator_tool_item'=>'GtkSeparatorToolItem.html',
			'gtk_separator_menu_item'=>'GtkSeparatorMenuItem.html',
			'gtk_separator'=>'GtkSeparator.html',
			'gtk_scrolled_window'=>'GtkScrolledWindow.html',
			'gtk_scrollbar'=>'GtkScrollbar.html',
			'gtk_scale'=>'GtkScale.html',
			'gtk_ruler'=>'GtkRuler.html',
			'gtk_range'=>'GtkRange.html',
			'gtk_radio_button'=>'GtkRadioButton.html',
			'gtk_radio_action'=>'GtkRadioAction.html',
			'gtk_radio_tool_button'=>'GtkRadioToolButton.html',
			'gtk_radio_menu_item'=>'GtkRadioMenuItem.html',
			'gtk_progress_bar'=>'GtkProgressBar.html',
			'gtk_progress'=>'GtkProgress.html',
			'gtk_preview'=>'GtkPreview.html',
			'gtk_plug'=>'GtkPlug.html',
			'gtk_pixmap'=>'GtkPixmap.html',
			'gtk_paned'=>'GtkPaned.html',
			'gtk_option_menu'=>'GtkOptionMenu.html',
			'gtk_old_editable'=>'GtkOldEditable.html',
			'gtk_object'=>'GtkObject.html',
			'gtk_notebook'=>'GtkNotebook.html',
			'gtk_misc'=>'GtkMisc.html',
			'gtk_message_dialog'=>'GtkMessageDialog.html',
			'gtk_menu_shell'=>'GtkMenuShell.html',
			'gtk_menu_item'=>'GtkMenuItem.html',
			'gtk_menu_bar'=>'GtkMenuBar.html',
			'gtk_menuTool_button'=>'GtkMenuToolButton.html',
			'gtk_menu'=>'GtkMenu.html',
			'gtk_list_store'=>'GtkListStore.html',
			'gtk_list_item'=>'GtkListItem.html',
			'gtk_list'=>'GtkList.html',
			'gtk_layout'=>'GtkLayout.html',
			'gtk_label'=>'GtkLabel.html',
			'gtk_item_factory'=>'GtkItemFactory.html',
			'gtk_item'=>'GtkItem.html',
			'gtk_invisible'=>'GtkInvisible.html',
			'gtk_input_dialog'=>'GtkInputDialog.html',
			'gtk_immulticontext'=>'GtkIMMulticontext.html',
			'gtk_imcontext_simple'=>'GtkIMContextSimple.html',
			'gtk_imcontext'=>'GtkIMContext.html',
			'gtk_image_menu_item'=>'GtkImageMenuItem.html',
			'gtk_image'=>'GtkImage.html',
			'gtk_icon_view'=>'GtkIconView.html',
			'gtk_icon_theme'=>'GtkIconTheme.html',
			'gtk_hseparator'=>'GtkHSeparator.html',
			'gtk_hscrollbar'=>'GtkHScrollbar.html',
			'gtk_hscale'=>'GtkHScale.html',
			'gtk_hruler'=>'GtkHRuler.html',
			'gtk_hpaned'=>'GtkHPaned.html',
			'gtk_hbutton_box'=>'GtkHButtonBox.html',
			'gtk_hbox'=>'GtkHBox.html',
			'gtk_handle_box'=>'GtkHandleBox.html',
			'gtk_gamma_curve'=>'GtkGammaCurve.html',
			'gtk_frame'=>'GtkFrame.html',
			'gtk_font_selection'=>'GtkFontSelection.html',
			'gtk_font_button'=>'GtkFontButton.html',
			'gtk_fontSelection_dialog'=>'GtkFontSelectionDialog.html',
			'gtk_fixed'=>'GtkFixed.html',
			'gtk_file_selection'=>'GtkFileSelection.html',
			'gtk_file_chooser'=>'GtkFileChooser.html',
			'gtk_file_chooser_widget'=>'GtkFileChooserWidget.html',
			'gtk_file_chooser_dialog'=>'GtkFileChooserDialog.html',
			'gtk_file_chooser_button'=>'GtkFileChooserButton.html',
			'gtk_expander'=>'GtkExpander.html',
			'gtk_event_box'=>'GtkEventBox.html',
			'gtk_entry_completion'=>'GtkEntryCompletion.html',
			'gtk_entry'=>'GtkEntry.html',
			'gtk_editable'=>'GtkEditable.html',
			'gtk_drawing_area'=>'GtkDrawingArea.html',
			'gtk_dialog'=>'GtkDialog.html',
			'gtk_curve'=>'GtkCurve.html',
			'gtk_ctree'=>'GtkCTree.html',
			'gtk_container'=>'GtkContainer.html',
			'gtk_combo_box'=>'GtkComboBox.html',
			'gtk_combo_box_entry'=>'GtkComboBoxEntry.html',
			'gtk_combo'=>'GtkCombo.html',
			'gtk_color_selection'=>'GtkColorSelection.html',
			'gtk_color_button'=>'GtkColorButton.html',
			'gtk_color_selection_dialog'=>'GtkColorSelectionDialog.html',
			'gtk_clist'=>'GtkCList.html',
			'gtk_check_button'=>'GtkCheckButton.html',
			'gtk_check_menu_item'=>'GtkCheckMenuItem.html',
			'gtk_cell_view'=>'GtkCellView.html',
			'gtk_cell_renderer'=>'GtkCellRenderer.html',
			'gtk_cell_layout'=>'GtkCellLayout.html',
			'gtk_cell_editable'=>'GtkCellEditable.html',
			'gtk_cell_renderer_toggle'=>'GtkCellRendererToggle.html',
			'gtk_cell_renderer_text'=>'GtkCellRendererText.html',
			'gtk_cell_renderer_progress'=>'GtkCellRendererProgress.html',
			'gtk_cell_renderer_pixbuf'=>'GtkCellRendererPixbuf.html',
			'gtk_cell_renderer_combo'=>'GtkCellRendererCombo.html',
			'gtk_calendar'=>'GtkCalendar.html',
			'gtk_button_box'=>'GtkButtonBox.html',
			'gtk_button'=>'GtkButton.html',
			'gtk_box'=>'GtkBox.html',
			'gtk_bin'=>'GtkBin.html',
			'gtk_aspect_frame'=>'GtkAspectFrame.html',
			'gtk_arrow'=>'GtkArrow.html',
			'gtk_alignment'=>'GtkAlignment.html',
			'gtk_adjustment'=>'GtkAdjustment.html',
			'gtk_action_group'=>'GtkActionGroup.html',
			'gtk_action'=>'GtkAction.html',
			'gtk_accessible'=>'GtkAccessible.html',
			'gtk_accel_label'=>'GtkAccelLabel.html',
			'gtk_about_dialog'=>'GtkAboutDialog.html'
		} #}}}4
		def initialize(f)
			@file = f
		end
		def gtk_fun_path(fun) #{{{3
			line=Vjde::get_loction_line(fun,File.dirname($0)+'/tlds/gtkdoc.txt')
			return nil if line==nil
			index = line.index(' ')+1
			fl = line[index..-2]
			return fl 
		end #}}}3
		def read_gtk(fun1) #{{{3
			fun = String.new(fun1)
			return unless File.exists?(@file)
			fn = gtk_fun_path(fun)
			return if fn == nil
			p = File.dirname(@file)+'/html/'+fn
			return unless File.exists?(p)
			return unless fun!=nil && fun!=''
			fun.gsub!('_','-')
			f = File.open(p)
			find = false
			lines = []
			index = 0
			f.each { |l|
				if !find
					find = true if l.index('<div class="refsect2" lang="en">')==0
					next
				end
				break if l.index('<hr>')==0
				if index == 1
					if l.index('<a name="'+fun+'"></a>')!=0
						find = false
						lines.clear
						index = 0
						next
					end
				end
				lines << l
				index = index + 1
			}
			f.close()
			lines.each { |l|
				str = l.gsub(RE_TAG){ |p| get_pattern($1) }
				str.sub!(/<a[^>]*$/,'<u>')
				str.sub!(/^[^<]*>/,'')
				str.strip!
				yield(str) if str.length>0
			}
		end
		#}}}3
		def get_pattern(name)
			return REP_PATTERNS[name] if REP_PATTERNS.has_key?(name)
			return ''
		end
	end
	#}}}2
end
#}}}1
#{{{1
	#puts $0
#$*.each_with_index { |v,i|
	#puts v
#}
if $*.length>=3
	doc_reader = Vjde::CppDocReader.new($*[0])
	index = 0
	str = ''
	doc_reader.read_gtk($*[2]) { |line|
		if index==0
			print line
			index =1 
			next
		end
		puts line
	}
end
puts "\n"
#}}}1
#{{{1
#puts Vjde::get_loction_line('g_string_insert_c','d:/workspace/vjde3/plugin/vjde/tlds/gtkdoc.txt')
#puts Vjde::get_loction_line('g_string_sprintf','~/.vim/vjde/g_.doc.txt')
#puts Vjde::get_loction_line('g_string_sprintfa','~/.vim/vjde/g_.doc.txt')
#puts Vjde::get_loction_line('GUINT16_SWAP_LE_BE','~/.vim/vjde/g_.doc.txt')
#puts Vjde::get_loction_line('GINT16_FROM_BExxx','~/.vim/vjde/g_.doc.txt')
#puts Vjde::get_loction_line('union','~/.vim/vjde/g_.doc.txt')
#puts Vjde::get_loction_line('g_type_is_a','d:/workspace/vjde3/plugin/vjde/tlds/gtkdoc.txt')
#puts Vjde::get_loction_line('gtk_label_set_text','d:/workspace/vjde3/plugin/vjde/tlds/gtkdoc.txt')
#reader = Vjde::CppDocReader.new('D:/GTK/share/gtk-doc/html')
#reader.read_gtk('gtk_window_set_title') { |lines|
	#puts lines
#}
#reader.read_gtk('gtk_window_get_modal') { |lines|
	#puts lines
#}
#}}}1

# vim:tw=72:fdm=marker:ts=4:sw=4:sts=4:
