module ApplicationHelper
  def title 
    [ "Occupy Richmond Media Events",
       @title ].reject(&:blank?).join(": ")
  end

  def list_fields_for object, *attr_list
    content_tag :dl do
      attr_list.collect do |attr|
        [ ( content_tag(:dt) { attr.titleize } ),
          ( content_tag(:dd) { object.send(attr) } ) ].join
      end.join
    end
  end
end
