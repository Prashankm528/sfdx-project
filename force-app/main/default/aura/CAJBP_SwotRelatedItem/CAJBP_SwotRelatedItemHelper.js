/**
 * Created by amirhafeez on 18/03/2020.
 */

({
    load: function(component) {
        const sortable = Sortable.create(component.find('sortable').getElement(), {
            scroll: true,
            scrollSensitivity: 100,
            scrollSpeed: 10,
            bubbleScroll: true,
            animation: 150,
            swapClass: 'sortable-ghost',
            ghostClass: 'sortable-ghost',
            chosenClass: 'sortable-chosen',
            dragClass: 'sortable-drag',
            easing: 'cubic-bezier(1, 0, 0, 1)',

            onUpdate: function(/**Event*/evt) {
                console.log('onUpdate');
                const swots = component.get('v.swots');

                const ids = sortable.toArray();
                const swotsToOrder = [];
                const swotsToUpdate = [];
                console.log(ids);

                for (const [index, id] of ids.entries()) {
                    console.log(index);
                    swotsToOrder.push(swots.filter(swot => swot.id === id)[0]);

                    swotsToUpdate.push({
                        sObjectType: 'CAJBP_SWOT__c',
                        Id: id,
                        CAJBP_Sort_Order__c: index
                    });
                }

                component.set('v.swots', swotsToOrder);

                component.getEvent('swotRelatedEvent').setParams({
                    swots: swotsToUpdate
                }).fire();
            }
        });
    }
});