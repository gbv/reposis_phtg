/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package de.gbv.reposis.phtg;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Text;
import org.jdom2.output.XMLOutputter;
import org.jsoup.Jsoup;
import org.mycore.common.MCRException;
import org.mycore.common.MCRMailer;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.frontend.MCRFrontendUtil;

public class VZGMailAgreementEventHandler extends MCREventHandlerBase {

    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        this.handleObjectUpdated(evt, obj);
    }

    @Override
    protected void handleObjectUpdated(MCREvent evt, MCRObject obj) {
        final ArrayList<String> currentAgreements = obj.getService().getFlags("agreement");

        if (currentAgreements.size() == 0) {
            return;
        }

        int oldAgreementsSize = 0;
        if (MCRMetadataManager.exists(obj.getId())) {
            final MCRObject retrieve = MCRMetadataManager.retrieveMCRObject(obj.getId());
            final ArrayList<String> oldAgreements = retrieve.getService().getFlags("agreement");
            oldAgreementsSize = oldAgreements.size();
        }

        if (oldAgreementsSize == 0 && currentAgreements.size() > 0) {
            // an agreement was added to the object, we should send the Mail now.
            final Document htmlPart = getHTMLPart(obj);
            final List<Content> html = new ArrayList<>(htmlPart.getRootElement().getContent()).stream()
                .map(Content::detach)
                .collect(Collectors.toList());

            final Element mailElement = createMailElement(MCRConfiguration2.getStringOrThrow("MCR.mir-module.MailSender"),
                MCRConfiguration2.getStringOrThrow("MCR.mir-module.EditorMail"),
                "Einverständniserklärung von " + MCRSessionMgr.getCurrentSession().getUserInformation().getUserID()
                    + " für " + obj.getId().toString(),
                html,
                MCRFrontendUtil.getBaseURL() + "content/publish/Einverständniserklärung_20220114_v1.0.pdf");
            try {
                MCRMailer.send(mailElement, true);
            } catch (Exception e) {
                throw new MCRException("Error while sending mail!", e);
            }
        }
    }

    private Element createMailElement(String from, String to, String subject, List<Content> htmlPartRoot,
        String fileResource) {
        final Element mailElement = new Element("email");

        final Element fromElement = new Element("from");
        fromElement.setText(from);

        final Element toElement = new Element("to");
        toElement.setText(to);

        final Element subjectElement = new Element("subject");
        subjectElement.setText(subject);

        final Element part = new Element("part");
        part.setText(fileResource);

        final Element textBody = new Element("body");
        textBody.setAttribute("type", "text");
        textBody.setText(getJdomAsString(htmlPartRoot));

        final Element htmlBody = new Element("body");
        htmlBody.setAttribute("type", "html");
        htmlBody.setText(getJdomAsString(htmlPartRoot));

        mailElement.addContent(fromElement);
        mailElement.addContent(toElement);
        mailElement.addContent(subjectElement);
        mailElement.addContent(textBody);
        mailElement.addContent(htmlBody);
        mailElement.addContent(part);

        return mailElement;
    }

    private String getJdomAsTextString(List<Content> htmlPartRoot){
        final String jdomAsString = getJdomAsString(htmlPartRoot);
        return Jsoup.parse(jdomAsString).text();
    }

    private String getJdomAsString(List<Content> htmlPartRoot) {
        return new XMLOutputter().outputString(htmlPartRoot);
    }

    public Document getHTMLPart(MCRObject obj) {
        try {
            final VZGMailXHTMLTemplate mailTemplate = new VZGMailXHTMLTemplate("agreement_mail_template.xhtml");
            final String userID = MCRSessionMgr.getCurrentSession().getUserInformation().getUserID();
            mailTemplate.replace("user", new Text(userID));

            final Element a = new Element("a");
            a.setAttribute("href", MCRFrontendUtil.getBaseURL() + "receive/" + obj.getId().toString());
            a.setText(obj.getId().toString());
            mailTemplate.replace("link", a);
            return mailTemplate.getDoc();
        } catch (IOException | JDOMException e) {
            throw new MCRException("Error while fill mail template!", e);
        }

    }
}
